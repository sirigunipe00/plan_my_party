import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

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
  const OpenMapSearch({
    this.client,
    this.endpoint = const String.fromEnvironment(
      'LOCATION_SEARCH_URL',
      defaultValue: 'https://nominatim.openstreetmap.org/search',
    ),
  });

  Future<List<VenuePick>> search(String query) async {
    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'q': query.trim(),
        'limit': '6',
        'format': 'jsonv2',
        'addressdetails': '1',
      },
    );
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
      throw StateError('Location search failed');
    }
    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data
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
  final cache = <String, List<VenuePick>>{};
  DateTime? lastSearch;
  int requestId = 0;
  bool searching = false;
  String? error;
  List<VenuePick> results = [];

  @override
  void initState() {
    super.initState();
    search = TextEditingController(
      text: widget.latitude != null && widget.longitude != null
          ? widget.location
          : '',
    );
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _onQuery(String value) {
    requestId++;
    widget.onQueryChanged?.call();
    setState(() {
      results = [];
      error = null;
      searching = false;
    });
  }

  void _submitSearch() {
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
    if (lastSearch != null &&
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
      final places = await (widget.lookup ?? const OpenMapSearch().search)(
        query,
      );
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
    setState(() {
      results = [];
      searching = false;
      error = null;
    });
    widget.onPicked(place);
    FocusScope.of(context).unfocus();
  }

  Widget _resultCard(VenuePick place) => Padding(
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
            child: Text(
              place.label,
              maxLines: widget.fill ? 2 : null,
              overflow: widget.fill ? TextOverflow.ellipsis : null,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _map() => FlutterMap(
    key: ValueKey('${widget.latitude},${widget.longitude}'),
    options: MapOptions(
      initialCenter: LatLng(widget.latitude!, widget.longitude!),
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
      MarkerLayer(
        markers: [
          Marker(
            point: LatLng(widget.latitude!, widget.longitude!),
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

  Widget _placeholder() => Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.lavender,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Text(
      'Search, then tap a place to pin it on the map.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: AppColors.deep),
    ),
  );

  Widget _fillBuild(bool hasPin) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        key: const ValueKey('event-location'),
        controller: search,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: 'Event Location',
          hintText: 'Enter a venue and city, then search',
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: AppColors.purple,
          ),
          suffixIcon: IconButton(
            tooltip: 'Search locations',
            onPressed: searching ? null : _submitSearch,
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
            children: results.take(4).map(_resultCard).toList(),
          ),
        )
      else ...[
        Expanded(
          child: hasPin
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _map(),
                )
              : _placeholder(),
        ),
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
          hintText: 'Enter a venue and city, then search',
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: AppColors.purple,
          ),
          suffixIcon: IconButton(
            tooltip: 'Search locations',
            onPressed: searching ? null : _submitSearch,
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
        )
      else
        SizedBox(height: 92, child: _placeholder()),
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
