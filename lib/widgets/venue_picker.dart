import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../data/india_places.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class VenuePick {
  final String label;
  final double latitude, longitude;
  const VenuePick(this.label, this.latitude, this.longitude);
}

class OpenMapSearch {
  final http.Client? client;
  final String endpoint;
  final bool includeIndiaCatalog;
  const OpenMapSearch({
    this.client,
    this.endpoint = const String.fromEnvironment(
      'LOCATION_SEARCH_URL',
      defaultValue: 'https://nominatim.openstreetmap.org/search',
    ),
    this.includeIndiaCatalog = true,
  });

  Future<List<VenuePick>> search(
    String query, {
    double? nearLat,
    double? nearLon,
  }) async {
    final cleaned = query.trim();
    final local = includeIndiaCatalog
        ? searchIndiaPlaces(
            cleaned,
            limit: 8,
            nearLat: nearLat,
            nearLon: nearLon,
          )
        : const <VenuePick>[];

    final enriched = cleaned.toLowerCase().contains('india')
        ? cleaned
        : '$cleaned, India';
    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'q': enriched,
        'limit': '10',
        'format': 'jsonv2',
        'addressdetails': '1',
        'countrycodes': 'in',
        // Bias (without restricting) results towards the area around the
        // current pin, so nearby matches rank first.
        if (nearLat != null && nearLon != null)
          'viewbox':
              '${nearLon - 0.6},${nearLat + 0.6},${nearLon + 0.6},${nearLat - 0.6}',
      },
    );
    try {
      final response =
          await (client == null
                  ? http.get(
                      uri,
                      headers: const {
                        'Accept': 'application/json',
                        'User-Agent': 'PlanMyParty/1.0 (celebration planner)',
                      },
                    )
                  : client!.get(
                      uri,
                      headers: const {
                        'Accept': 'application/json',
                        'User-Agent': 'PlanMyParty/1.0 (celebration planner)',
                      },
                    ))
              .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        if (local.isNotEmpty) return local;
        throw StateError('Location search failed');
      }
      final data = jsonDecode(response.body);
      final remote = data is! List
          ? const <VenuePick>[]
          : data
                .whereType<Map>()
                .map((row) {
                  final latitude = double.tryParse('${row['lat']}');
                  final longitude = double.tryParse('${row['lon']}');
                  final label = '${row['display_name'] ?? ''}'.trim();
                  if (latitude == null ||
                      longitude == null ||
                      label.isEmpty ||
                      !latitude.isFinite ||
                      !longitude.isFinite ||
                      latitude.abs() > 90 ||
                      longitude.abs() > 180) {
                    return null;
                  }
                  return VenuePick(label, latitude, longitude);
                })
                .whereType<VenuePick>()
                .toList();
      return _mergePlaces(local, remote, nearLat: nearLat, nearLon: nearLon);
    } catch (_) {
      if (local.isNotEmpty) return local;
      rethrow;
    }
  }

  List<VenuePick> _mergePlaces(
    List<VenuePick> local,
    List<VenuePick> remote, {
    double? nearLat,
    double? nearLon,
  }) {
    final seen = <String>{};
    final merged = <VenuePick>[];
    for (final place in [...local, ...remote]) {
      final key = place.label.toLowerCase();
      if (!seen.add(key)) continue;
      merged.add(place);
    }
    if (nearLat != null && nearLon != null) {
      double distance(VenuePick place) {
        final dLat = place.latitude - nearLat;
        final dLon = place.longitude - nearLon;
        return dLat * dLat + dLon * dLon;
      }

      merged.sort((a, b) => distance(a).compareTo(distance(b)));
    }
    return merged.take(8).toList();
  }
}

class VenuePicker extends StatefulWidget {
  final String location;
  final double? latitude, longitude;
  final ValueChanged<VenuePick> onPicked;
  final VoidCallback? onQueryChanged;
  final Future<List<VenuePick>> Function(String)? lookup;

  /// Fills the height it is given (no scrolling): the map or the results take
  /// the remaining space instead of a fixed height.
  final bool fill;
  const VenuePicker({
    super.key,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.onPicked,
    this.onQueryChanged,
    this.lookup,
    this.fill = false,
  });

  @override
  State<VenuePicker> createState() => _VenuePickerState();
}

class _VenuePickerState extends State<VenuePicker> {
  late final TextEditingController search;
  static const _searcher = OpenMapSearch();
  final cache = <String, List<VenuePick>>{};
  Timer? _debounce;
  DateTime? lastSearch;
  int requestId = 0;
  bool searching = false;
  String? error;
  List<VenuePick> results = [];
  double? _focusLat, _focusLon;

  @override
  void initState() {
    super.initState();
    search = TextEditingController(
      text: widget.latitude != null && widget.longitude != null
          ? widget.location
          : '',
    );
    _focusLat = widget.latitude;
    _focusLon = widget.longitude;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    search.dispose();
    super.dispose();
  }

  void _onQuery(String value) {
    requestId++;
    widget.onQueryChanged?.call();
    _debounce?.cancel();
    setState(() {
      results = [];
      error = null;
      searching = false;
    });
    final query = value.trim();
    if (query.length < 3) return;
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _submitSearch(fromTyping: true);
    });
  }

  void _submitSearch({bool fromTyping = false}) {
    final query = search.text.trim();
    if (query.length < 3) {
      setState(
        () => error = 'Enter at least 3 characters, including a city or area.',
      );
      return;
    }
    if (searching) return;
    final cached = cache[query.toLowerCase()];
    if (cached != null) {
      setState(() {
        results = cached;
        error = cached.isEmpty
            ? 'No matching places. Try a nearby area or city.'
            : null;
      });
      return;
    }
    final now = DateTime.now();
    if (!fromTyping &&
        lastSearch != null &&
        now.difference(lastSearch!) < const Duration(seconds: 1)) {
      return;
    }
    lastSearch = now;
    final id = ++requestId;
    setState(() {
      searching = true;
      error = null;
      results = [];
    });
    _search(query, id);
  }

  Future<void> _search(String query, int id) async {
    try {
      final lookup = widget.lookup;
      final places = await (lookup != null
          ? lookup(query)
          : _searcher.search(query, nearLat: _focusLat, nearLon: _focusLon));
      if (!mounted) return;
      cache[query.toLowerCase()] = places;
      if (id != requestId) return;
      setState(() {
        results = places;
        searching = false;
        error = places.isEmpty
            ? 'No matching places. Try another name or area.'
            : null;
      });
    } catch (_) {
      if (!mounted || id != requestId) return;
      setState(() {
        searching = false;
        error = 'Location search is unavailable. Please try again.';
      });
    }
  }

  void _select(VenuePick place) {
    requestId++;
    search.text = place.label;
    _focusLat = place.latitude;
    _focusLon = place.longitude;
    setState(() {
      results = [];
      searching = false;
      error = null;
    });
    widget.onPicked(place);
    FocusScope.of(context).unfocus();
  }

  Widget _resultCard(VenuePick place) {
    final comma = place.label.indexOf(',');
    final title = comma == -1 ? place.label : place.label.substring(0, comma);
    final subtitle = comma == -1
        ? ''
        : place.label.substring(comma + 1).trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PartyCard(
        padding: const EdgeInsets.all(12),
        onTap: () => _select(place),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.purple,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _map() {
    final point = LatLng(widget.latitude!, widget.longitude!);
    return FlutterMap(
      key: ValueKey('${widget.latitude},${widget.longitude}'),
      options: MapOptions(
        initialCenter: point,
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.planmyparty.plan_my_party',
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: point,
              radius: 220,
              useRadiusInMeter: true,
              color: AppColors.purple.withValues(alpha: .18),
              borderColor: AppColors.purple,
              borderStrokeWidth: 2,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 36,
              height: 36,
              alignment: Alignment.topCenter,
              child: const Icon(
                Icons.location_on,
                color: AppColors.purple,
                size: 36,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fillBuild(bool hasPin) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        key: const ValueKey('event-location'),
        controller: search,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: 'Event Location',
          hintText: 'Search flat no, building, area or landmark',
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: AppColors.purple,
          ),
          suffixIcon: IconButton(
            tooltip: 'Search locations',
            onPressed: searching ? null : () => _submitSearch(),
            icon: const Icon(Icons.search, color: AppColors.purple),
          ),
        ),
        onChanged: _onQuery,
        onSubmitted: (_) => _submitSearch(),
      ),
      if (searching) ...[
        gap8,
        const LinearProgressIndicator(minHeight: 2, color: AppColors.purple),
      ],
      if (error != null) ...[
        gap8,
        Text(error!, style: const TextStyle(fontSize: 11)),
      ],
      gap12,
      if (results.isNotEmpty)
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Suggestions',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple,
                  ),
                ),
              ),
              ...results.take(5).map(_resultCard),
            ],
          ),
        )
      else ...[
        if (hasPin)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _map(),
            ),
          )
        else
          const Spacer(),
        if (hasPin) ...[
          gap8,
          Text(
            widget.location,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, height: 1.45),
          ),
        ],
      ],
      gap8,
      const Text(
        '© OpenStreetMap contributors',
        style: TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => widget.fill
      ? _fillBuild(widget.latitude != null && widget.longitude != null)
      : _scrollBuild();

  Widget _scrollBuild() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Where’s the party?',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      gap8,
      TextField(
        key: const ValueKey('event-location'),
        controller: search,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: 'Event Location',
          hintText: 'Search flat no, building, area or landmark',
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: AppColors.purple,
          ),
          suffixIcon: IconButton(
            tooltip: 'Search locations',
            onPressed: searching ? null : () => _submitSearch(),
            icon: const Icon(Icons.search, color: AppColors.purple),
          ),
        ),
        onChanged: _onQuery,
        onSubmitted: (_) => _submitSearch(),
      ),
      if (searching) ...[
        gap8,
        const LinearProgressIndicator(minHeight: 2, color: AppColors.purple),
      ],
      if (error != null) ...[
        gap8,
        Text(error!, style: const TextStyle(fontSize: 11)),
      ],
      if (results.isNotEmpty) ...[gap8, ...results.map(_resultCard)],
      if (widget.latitude != null && widget.longitude != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(height: 180, child: _map()),
        ),
      if (widget.latitude != null && widget.longitude != null) ...[
        gap8,
        Text(
          widget.location,
          style: const TextStyle(fontSize: 11, height: 1.45),
        ),
      ],
      gap8,
      const Text(
        '© OpenStreetMap contributors',
        style: TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    ],
  );
}
