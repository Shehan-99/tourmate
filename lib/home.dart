import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'storage.dart'; // Import your storage page
import 'search_page.dart'; // Import your custom search delegate
import 'recycle_bin.dart'; // Import the Recycle Bin page

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadCamera();
    loadmodel();
  }

  Future<void> loadCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await cameraController!.initialize();
    cameraController!.startImageStream((imageStream) {
      cameraImage = imageStream;
      runModel();
    });
  }

  Future<void> runModel() async {
    if (cameraImage != null) {
      var predictions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      predictions!.forEach((element) {
        setState(() {
          output = element['label'];
        });
      });
    }
  }

  Future<void> loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Live Fruit Classification'),
        backgroundColor: Color.fromARGB(255, 66, 219, 240),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 66, 219, 240),
              ),
              child: Text(
                'Tour Mate ✈',
                style: TextStyle(
                  fontSize: 35,
                ),
              ),
            ),
            ListTile(
              title: Text('🔎 Search'),
              onTap: () {
                Navigator.of(context).pop();
                showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(
                      onSearchResultSelected: (String query) {
                        // Handle the selected search result here
                      },
                    ));
              },
            ),
            ListTile(
              title: Text('💾 Storage'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToStoragePage();
              },
            ),
            ListTile(
              title: Text('⏳ Recycle Bin'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToRecycleBinPage();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              width: MediaQuery.of(context).size.width,
              child: cameraController != null &&
                      cameraController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: cameraController!.value.aspectRatio,
                      child: CameraPreview(cameraController!),
                    )
                  : Container(),
            ),
          ),
          Text(
            output,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              backgroundColor: Color.fromARGB(255, 161, 214, 214),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 40, // Change the height as needed
        width: 100, // Change the width as needed
        child: FloatingActionButton.extended(
          onPressed: _captureImage,
          backgroundColor: Color(0xFF44C7CB),
          icon: Icon(Icons.camera_alt),
          label: Text('Capture'),
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    if (cameraController!.value.isInitialized) {
      XFile? imageFile = await cameraController!.takePicture();
      _saveImage(imageFile.path);
    }
  }

  Future<void> _saveImage(String imagePath) async {
    try {
      // Get the directory for saving images
      final directory = await getApplicationDocumentsDirectory();
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String path = '${directory.path}/$fileName.png';

      // Copy the image file to the new path
      await File(imagePath).copy(path);

      // Optionally, you can display a message to confirm that the image is saved
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image saved successfully!'),
        ),
      );
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  void _navigateToStoragePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoragePage()),
    );
  }

  void _navigateToRecycleBinPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecycleBinPage()),
    );
  }
}
