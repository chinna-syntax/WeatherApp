import 'package:flutter_test/flutter_test.dart';
import 'package:nimbus/app.dart';

void main() {
  testWidgets('Nimbus app builds', (tester) async {
    await tester.pumpWidget(const NimbusApp());
    expect(find.byType(NimbusApp), findsOneWidget);
  });
}
