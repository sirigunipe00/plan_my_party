import 'package:flutter_test/flutter_test.dart';
import 'package:plan_my_party/models/models.dart';
import 'package:plan_my_party/services/order_charges.dart';

void main() {
  test('order charges grow with distance and selected quantities', () {
    final near = calculateOrderCharges(
      lines: [
        ServiceLine(
          id: 'chairs',
          group: 'Furniture',
          name: 'Guest chairs',
          price: 2500,
          quantity: 1,
        ),
      ],
      latitude: 17.39,
      longitude: 78.49,
    );
    final far = calculateOrderCharges(
      lines: [
        ServiceLine(
          id: 'chairs',
          group: 'Furniture',
          name: 'Guest chairs',
          price: 2500,
          quantity: 4,
        ),
      ],
      latitude: 17.55,
      longitude: 78.60,
    );
    expect(near.delivery, greaterThan(0));
    expect(near.pickup, greaterThan(0));
    expect(near.setup, greaterThan(0));
    expect(near.taxable, near.items + near.extras);
    expect(
      near.gst,
      closeTo(near.taxable * OrderCharges.gstRate, 0.01),
    );
    expect(near.grandTotal, closeTo(near.taxable + near.gst, 0.001));
    expect(far.grandTotal, greaterThan(near.grandTotal));
    expect(far.distanceKm, greaterThan(near.distanceKm));
  });
}
