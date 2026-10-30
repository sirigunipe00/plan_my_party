import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';
import 'common.dart';

class VenuePick {
  final String label;
  final double latitude, longitude;
  const VenuePick(this.label, this.latitude, this.longitude);
}

class VenuePicker extends StatefulWidget {
  final String location;
  final double? latitude, longitude;
  final ValueChanged<VenuePick> onPicked;
  const VenuePicker({
    super.key,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.onPicked,
  });

  @override
  State<VenuePicker> createState() => _VenuePickerState();
}

class _VenuePickerState extends State<VenuePicker> {
  final search = TextEditingController();
  final mapController = MapController();
  Timer? debounce;
  int requestId = 0;
  bool searching = false;
  String? error;
  List<VenuePick> results = [];

  @override
  void dispose() {
    debounce?.cancel();
    search.dispose();
    mapController.dispose();
    super.dispose();
  }

  void _onQuery(String value) {
    debounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        results = [];
        error = null;
        searching = false;
      });
      return;
    }
    debounce = Timer(const Duration(milliseconds: 450), () => _search(query));
  }

  Future<void> _search(String query) async {
    final id = ++requestId;
    setState(() {
      searching = true;
      error = null;
    });
    try {
      final places = await _lookup(query);
      if (!mounted || id != requestId) return;
      setState(() {
        results = places;
        searching = false;
        error = places.isEmpty ? 'No matching places. Try another name.' : null;
      });
    } catch (_) {
      if (!mounted || id != requestId) return;
      setState(() {
        searching = false;
        error = 'Map search is unavailable right now. Try again.';
      });
    }
  }

  Future<List<VenuePick>> _lookup(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '6',
    });
    final response = await http
        .get(
          uri,
          headers: const {
            'User-Agent': 'PlanMyParty/1.0 (celebration planner)',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw StateError('Map search failed');
    }
    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((row) {
          final lat = double.tryParse('${row['lat']}');
          final lng = double.tryParse('${row['lon']}');
          final label = '${row['display_name'] ?? ''}'.trim();
          if (lat == null || lng == null || label.isEmpty) return null;
          return VenuePick(label, lat, lng);
        })
        .whereType<VenuePick>()
        .toList();
  }

  void _select(VenuePick place) {
    FocusScope.of(context).unfocus();
    final mapReady = widget.latitude != null && widget.longitude != null;
    setState(() => results = []);
    search.clear();
    widget.onPicked(place);
    if (mapReady) {
      mapController.move(LatLng(place.latitude, place.longitude), 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.latitude != null && widget.longitude != null;
    return Column(
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
          controller: search,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search a venue or area on the map',
            prefixIcon: Icon(Icons.search, color: AppColors.purple),
          ),
          onChanged: _onQuery,
          onSubmitted: (value) {
            debounce?.cancel();
            if (value.trim().length >= 3) _search(value.trim());
          },
        ),
        if (searching) ...[
          gap12,
          const LinearProgressIndicator(minHeight: 2, color: AppColors.purple),
        ],
        if (error != null) ...[
          gap8,
          Text(error!, style: const TextStyle(fontSize: 11)),
        ],
        if (results.isNotEmpty) ...[
          gap12,
          ...results.map(
            (place) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PartyCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        gap12,
        if (selected)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 180,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(widget.latitude!, widget.longitude!),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
              ),
            ),
          )
        else
          Container(
            height: 92,
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
          ),
        if (widget.location.trim().isNotEmpty) ...[
          gap8,
          Text(
            selected ? widget.location : 'Current venue: ${widget.location}',
            style: const TextStyle(fontSize: 11, height: 1.45),
          ),
        ],
      ],
    );
  }
}
