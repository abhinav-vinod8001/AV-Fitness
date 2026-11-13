import 'package:flutter_test/flutter_test.dart';
import 'package:irontrack_watch/main.dart';

void main() {
  testWidgets('Wear OS App initializes and renders Home Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const IronTrackWatchApp());
    expect(find.byType(IronTrackWatchApp), findsOneWidget);
    expect(find.text('OFFLINE'), findsOneWidget);
    expect(find.text('BPM'), findsOneWidget);
  });
}
