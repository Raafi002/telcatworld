import 'package:flutter_test/flutter_test.dart';
import 'package:telcat_world/main.dart';

void main() {
  testWidgets('TelCat World app renders shell navigation with 3 menus and FAB', (WidgetTester tester) async {
    await tester.pumpWidget(const TelCatWorldApp());
    await tester.pumpAndSettle();

    // Verify 3 bottom navigation labels
    expect(find.text('Cat-Dex'), findsWidgets);
    expect(find.text('Peta'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Verify Floating 'Pindai QR' button
    expect(find.text('Pindai QR'), findsOneWidget);
  });
}
