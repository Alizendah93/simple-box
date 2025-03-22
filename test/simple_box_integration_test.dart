import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_box/simple_box.dart';

class CounterState extends SimpleBoxState {
  final int count;
  CounterState(this.count);
}

class CounterBox extends SimpleBox<SimpleBoxState> {
  void increment() {
    if (currentState is CounterState) {
      final current = (currentState as CounterState).count;
      updateState(CounterState(current + 1));
    } else {
      updateState(CounterState(1));
    }
  }

  void decrement() {
    if (currentState is CounterState) {
      final current = (currentState as CounterState).count;
      updateState(CounterState(current - 1));
    } else {
      updateState(CounterState(0));
    }
  }

  // Helper for tests
  SimpleBoxState get currentState => _currentState;
  SimpleBoxState _currentState = InitialState();

  @override
  void updateState(SimpleBoxState state) {
    _currentState = state;
    super.updateState(state);
  }
}

class CounterWidget extends StatelessWidget {
  final CounterBox counterBox;
  final String label;

  const CounterWidget({
    super.key,
    required this.counterBox,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleBoxWidget<SimpleBoxState>(
      simpleBox: counterBox,
      builder: (state) {
        final count = state is CounterState ? state.count : 0;
        return Column(
          children: [
            Text('$label: $count'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: counterBox.decrement,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: counterBox.increment,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

void main() {
  group('SimpleBox Integration Tests', () {
    testWidgets(
      'Multiple widgets with same SimpleBox instance update together',
      (WidgetTester tester) async {
        final counterBox = CounterBox();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  CounterWidget(counterBox: counterBox, label: 'Counter 1'),
                  CounterWidget(counterBox: counterBox, label: 'Counter 2'),
                ],
              ),
            ),
          ),
        );

        // Verify initial state
        expect(find.text('Counter 1: 0'), findsOneWidget);
        expect(find.text('Counter 2: 0'), findsOneWidget);

        // Increment counter
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pump();

        // Both widgets should update
        expect(find.text('Counter 1: 1'), findsOneWidget);
        expect(find.text('Counter 2: 1'), findsOneWidget);

        // Decrement counter from second widget
        await tester.tap(find.byIcon(Icons.remove).last);
        await tester.pump();

        // Both widgets should update
        expect(find.text('Counter 1: 0'), findsOneWidget);
        expect(find.text('Counter 2: 0'), findsOneWidget);
      },
    );

    testWidgets('Multiple SimpleBox instances remain independent', (
      WidgetTester tester,
    ) async {
      final counterBox1 = CounterBox();
      final counterBox2 = CounterBox();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CounterWidget(counterBox: counterBox1, label: 'Counter 1'),
                CounterWidget(counterBox: counterBox2, label: 'Counter 2'),
              ],
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Counter 1: 0'), findsOneWidget);
      expect(find.text('Counter 2: 0'), findsOneWidget);

      // Increment first counter
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();

      // Only first widget should update
      expect(find.text('Counter 1: 1'), findsOneWidget);
      expect(find.text('Counter 2: 0'), findsOneWidget);

      // Increment second counter twice
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pump();

      // Counters should have different values
      expect(find.text('Counter 1: 1'), findsOneWidget);
      expect(find.text('Counter 2: 2'), findsOneWidget);
    });

    testWidgets('SimpleBox properly handles widget rebuilds', (
      WidgetTester tester,
    ) async {
      final counterBox = CounterBox();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterWidget(counterBox: counterBox, label: 'Counter'),
          ),
        ),
      );

      // Verify reference count
      expect(counterBox.referenceCount, 1);

      // Increment counter
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify state updated
      expect(find.text('Counter: 1'), findsOneWidget);

      // Rebuild with same SimpleBox instance
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterWidget(
              counterBox: counterBox,
              label: 'Updated Counter',
            ),
          ),
        ),
      );

      // Reference count should still be 1 (same widget)
      expect(counterBox.referenceCount, 1);

      // State should be preserved
      expect(find.text('Updated Counter: 1'), findsOneWidget);
    });
  });
}
