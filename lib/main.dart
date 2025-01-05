import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Palm Scan detection with OpenCV (Here it's simplified with image hashing)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(camera: cameras.first));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  MyApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palm Payment Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PalmScanner(camera: camera),
    );
  }
}

class PalmScanner extends StatefulWidget {
  final CameraDescription camera;

  PalmScanner({required this.camera});

  @override
  _PalmScannerState createState() => _PalmScannerState();
}

class _PalmScannerState extends State<PalmScanner> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to capture image and process it (hashing for comparison)
  Future<void> processPalmScan() async {
    try {
      final image = await _controller.takePicture();
      final imageData = await image.readAsBytes();

      // Convert image to hash for simple comparison (you can replace this with contour detection in OpenCV later)
      String imageHash = await generateImageHash(imageData);

      print("Palm Scan Hash: $imageHash");

      // Example of comparing the hash with a stored hash (simulated here)
      String storedHash =
          "example_stored_hash"; // Replace this with your actual hash
      bool isSameHand = await comparePalmScans(imageData, storedHash);
      if (isSameHand) {
        print("Palm matches the stored one!");
      } else {
        print("Palm does not match.");
      }
    } catch (e) {
      print("Error capturing palm scan: $e");
    }
  }

  // Generate hash for palm scan image
  Future<String> generateImageHash(Uint8List imageBytes) async {
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;
    img.Image grayscaleImage = img.grayscale(image);
    img.Image resizedImage =
        img.copyResize(grayscaleImage, width: 100, height: 100);

    List<int> imageData = resizedImage.getBytes();
    var hash = md5.convert(imageData);

    return hash.toString();
  }

  // Compare palm scan hash with stored hash
  Future<bool> comparePalmScans(
      Uint8List newScanData, String storedHash) async {
    String newScanHash = await generateImageHash(newScanData);
    return newScanHash == storedHash; // Simple hash comparison
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Palm Payment Demo'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: processPalmScan,
        child: Icon(Icons.camera),
      ),
    );
  }
}
