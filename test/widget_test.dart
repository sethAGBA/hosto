// Basic widget test for the Res Hopital UI.

import 'package:flutter_test/flutter_test.dart';
import 'package:hosto/app.dart';

void main() {
  testWidgets('App loads dashboard and navigates to patients', (WidgetTester tester) async {
    await tester.pumpWidget(const ResHopitalApp());
    await tester.pumpAndSettle();

    expect(find.text('Tableau de bord'), findsWidgets);
    expect(find.text('Chiffres clés du jour'), findsOneWidget);

    await tester.tap(find.text('Patients'));
    await tester.pumpAndSettle();

    expect(find.text('Registre des patients'), findsOneWidget);
  });
}
