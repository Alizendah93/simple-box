import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_box/simple_box.dart';

class TestState extends SimpleBoxState {
  final int value;
  TestState(this.value);
}

class TestBox extends SimpleBox<SimpleBoxState> {
  void updateTestState(SimpleBoxState state) {
    updateState(state);
  }
}

void main() {
  group('SimpleBoxWidget', () {
    late TestBox testBox;
    
    setUp(() {
      testBox = TestBox();
    });
    
    testWidgets('builds with initial state', (WidgetTester tester) async {
      // Build widget with SimpleBox
      await tester.pumpWidget(
        MaterialApp(
          home: SimpleBoxWidget<SimpleBoxState>(
            simpleBox: testBox,
            builder: (state) {
              return Text(state is InitialState ? 'Initial' : 'Other');
            },
          ),
        ),
      );
      
      // Verify reference count increased
      expect(testBox.referenceCount, 1);
      
      // Verify initial state is rendered
      expect(find.text('Initial'), findsOneWidget);
    });
    
    testWidgets('updates UI when state changes', (WidgetTester tester) async {
      // Build widget with SimpleBox
      await tester.pumpWidget(
        MaterialApp(
          home: SimpleBoxWidget<SimpleBoxState>(
            simpleBox: testBox,
            builder: (state) {
              if (state is TestState) {
                return Text('Value: ${state.value}');
              }
              return const Text('Initial');
            },
          ),
        ),
      );
      
      // Verify initial state
      expect(find.text('Initial'), findsOneWidget);
      
      // Update state
      testBox.updateTestState(TestState(42));
      await tester.pump();
      
      // Verify UI updated
      expect(find.text('Value: 42'), findsOneWidget);
    });
    
    testWidgets('calls listener when state changes', (WidgetTester tester) async {
      SimpleBoxState? capturedState;
      
      // Build widget with SimpleBox and listener
      await tester.pumpWidget(
        MaterialApp(
          home: SimpleBoxWidget<SimpleBoxState>(
            simpleBox: testBox,
            listener: (state) {
              capturedState = state;
            },
            builder: (state) => const SizedBox(),
          ),
        ),
      );
      
      // Initial state should be captured
      expect(capturedState, isA<InitialState>());
      
      // Update state
      final testState = TestState(99);
      testBox.updateTestState(testState);
      await tester.pump();
      
      // Verify listener was called with new state
      expect(capturedState, equals(testState));
    });
    
    testWidgets('disposes SimpleBox when widget is removed', (WidgetTester tester) async {
      // Build widget with SimpleBox
      await tester.pumpWidget(
        MaterialApp(
          home: SimpleBoxWidget<SimpleBoxState>(
            simpleBox: testBox,
            builder: (state) => const SizedBox(),
          ),
        ),
      );
      
      // Verify reference count increased
      expect(testBox.referenceCount, 1);
      expect(testBox.isDisposed, false);
      
      // Remove widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      
      // Verify reference count decreased and box is disposed
      expect(testBox.referenceCount, 0);
      expect(testBox.isDisposed, true);
    });
    
    testWidgets('multiple widgets can share same SimpleBox', (WidgetTester tester) async {
      // Build two widgets with the same SimpleBox
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              SimpleBoxWidget<SimpleBoxState>(
                simpleBox: testBox,
                builder: (state) => const Text('Widget 1'),
              ),
              SimpleBoxWidget<SimpleBoxState>(
                simpleBox: testBox,
                builder: (state) => const Text('Widget 2'),
              ),
            ],
          ),
        ),
      );
      
      // Verify reference count is 2
      expect(testBox.referenceCount, 2);
      
      // Remove one widget
      await tester.pumpWidget(
        MaterialApp(
          home: SimpleBoxWidget<SimpleBoxState>(
            simpleBox: testBox,
            builder: (state) => const Text('Widget 1'),
          ),
        ),
      );
      
      // Verify reference count decreased but box is not disposed
      expect(testBox.referenceCount, 1);
      expect(testBox.isDisposed, false);
      
      // Remove the last widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      
      // Verify box is now disposed
      expect(testBox.referenceCount, 0);
      expect(testBox.isDisposed, true);
    });
  });
}