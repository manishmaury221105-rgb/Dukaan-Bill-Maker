import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dukaan_bill_maker/main.dart';
import 'package:dukaan_bill_maker/screens/splash_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts with SplashScreen and title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DukaanBillMakerApp());

    // Verify that SplashScreen is displayed
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Dukaan Bill Maker'), findsOneWidget);

    // Advance timer to let splash complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
