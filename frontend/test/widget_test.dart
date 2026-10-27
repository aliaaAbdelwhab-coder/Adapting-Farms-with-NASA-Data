import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('FieldShift welcome screen loads correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FieldShiftApp());
    await tester.pumpAndSettle();

    expect(find.text('FieldShift'), findsOneWidget);
    expect(find.text('Adapt your farm.\nGrow smarter.'), findsOneWidget);
    expect(
      find.text(
        'Smart crop rotation powered by Earth observation data.',
      ),
      findsOneWidget,
    );
    expect(find.text('Analyze My Farm'), findsOneWidget);
    expect(find.text('Explore Demo Farm'), findsOneWidget);
  });
}