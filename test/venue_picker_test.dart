import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plan_my_party/theme/app_theme.dart';
import 'package:plan_my_party/widgets/common.dart';
import 'package:plan_my_party/widgets/venue_picker.dart';

void main() {
  test('OpenStreetMap search requests places and parses coordinates', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'nominatim.openstreetmap.org');
      expect(request.method, 'GET');
      expect(request.url.queryParameters['format'], 'jsonv2');
      expect(request.url.queryParameters['countrycodes'], 'in');
      expect(request.url.queryParameters['q'], 'Sunny Hall, India');
      return http.Response(
        jsonEncode([
          {
            'display_name': 'Sunny Hall, Hyderabad',
            'lat': '17.4',
            'lon': '78.4',
          },
        ]),
        200,
      );
    });
    final places = await OpenMapSearch(
      client: client,
      includeIndiaCatalog: false,
    ).search('Sunny Hall');
    expect(places.single.label, 'Sunny Hall, Hyderabad');
    expect(places.single.latitude, 17.4);
    expect(places.single.longitude, 78.4);
    client.close();
  });

  test('India catalog suggests door numbers and localities', () async {
    final client = MockClient((_) async => http.Response('[]', 200));
    final places = await OpenMapSearch(client: client).search(
      'Door No. 12-2-418 Asif',
    );
    expect(places, isNotEmpty);
    expect(places.any((place) => place.label.contains('Asif Nagar')), isTrue);
    client.close();
  });

  test('API failures are reported', () async {
    final client = MockClient((_) async => http.Response('{}', 403));
    await expectLater(
      OpenMapSearch(client: client, includeIndiaCatalog: false).search('Hall'),
      throwsStateError,
    );
    client.close();
  });

  testWidgets('search results select a place and ignore stale requests', (
    tester,
  ) async {
    final first = Completer<List<VenuePick>>();
    VenuePick? picked;
    var cleared = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: partyTheme(),
        home: Scaffold(
          body: VenuePicker(
            location: '',
            latitude: null,
            longitude: null,
            onPicked: (place) => picked = place,
            onQueryChanged: () => cleared++,
            lookup: (query) => query == 'Old venue'
                ? first.future
                : Future.value([
                    const VenuePick('New venue, Hyderabad', 17.4, 78.4),
                  ]),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Old venue');
    await tester.tap(find.byTooltip('Search locations'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'New venue');
    first.complete([const VenuePick('Old venue', 1, 2)]);
    await tester.pump();
    expect(find.text('Old venue'), findsNothing);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.tap(find.byTooltip('Search locations'));
    await tester.pump();
    await tester.tap(find.widgetWithText(PartyCard, 'New venue'));
    await tester.pumpAndSettle();
    expect(picked!.latitude, 17.4);
    expect(picked!.label, 'New venue, Hyderabad');
    expect(cleared, 2);
    await tester.enterText(find.byType(TextField), 'ab');
    await tester.pumpAndSettle();
    expect(cleared, 3);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
