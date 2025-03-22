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
  group('SimpleBox', () {
    late TestBox testBox;

    setUp(() {
      testBox = TestBox();
    });

    test('initial state', () {
      expect(testBox.referenceCount, 0);
      expect(testBox.isDisposed, false);
    });

    test('reference counting', () {
      testBox.addReference();
      expect(testBox.referenceCount, 1);

      testBox.addReference();
      expect(testBox.referenceCount, 2);

      testBox.removeReference();
      expect(testBox.referenceCount, 1);
      expect(testBox.isDisposed, false);

      testBox.removeReference();
      expect(testBox.referenceCount, 0);
      expect(testBox.isDisposed, true);
    });

    test('dispose closes stream', () {
      testBox.addReference();
      testBox.removeReference(); // This should dispose the box

      // Attempting to update state after disposal should not throw
      // but the state should not be updated
      expect(() => testBox.updateTestState(TestState(1)), returnsNormally);
    });

    test('multiple references only dispose once', () {
      testBox.addReference();
      testBox.addReference();

      testBox.removeReference();
      expect(testBox.isDisposed, false);

      testBox.removeReference();
      expect(testBox.isDisposed, true);

      // Additional removals should not cause issues
      expect(() => testBox.removeReference(), returnsNormally);
    });
  });
}
