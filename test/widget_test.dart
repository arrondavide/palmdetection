import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:palm_payment_demo/main.dart';

// Mock camera data for testing
class MockCamera extends CameraDescription {
  MockCamera()
      : super(
            name: '1', // Use the name parameter instead of deviceId
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0);
}

void main() {
  testWidgets('Test Palm Payment App with Mock Camera',
      (WidgetTester tester) async {
    // Simulate the available cameras fetching process
    final List<CameraDescription> cameras = [MockCamera()];

    // Build our app with the mock camera
    await tester.pumpWidget(MyApp(camera: cameras.first));

    // Wait for async operations to complete (camera initialization)
    await tester.pumpAndSettle();

    // Verify that camera-related widgets are present
    expect(find.byType(PalmScanner), findsOneWidget);
    expect(find.byType(CameraPreview), findsOneWidget);
  });
}
