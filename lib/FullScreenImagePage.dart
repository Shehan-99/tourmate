import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StoragePage()),
            );
          },
          child: Text('Go to Storage Page'),
        ),
      ),
    );
  }
}

class StoragePage extends StatefulWidget {
  const StoragePage({Key? key}) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    setState(() {
      _images = files.whereType<File>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Gallery',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _images.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FullScreenImagePage(imagePath: _images[index].path),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(_images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        backgroundColor: Color(0xFF44C7CB),
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Future<void> _captureImage() async {
    // Simulate capturing an image and saving it to device storage
    // For demonstration purposes, we'll just save a dummy image
    // You can integrate this with your actual image capture logic

    final ByteData bytes = await rootBundle.load('assets/dummy_image.jpg');
    final String path = (await getTemporaryDirectory()).path;
    final File image = File('$path/dummy_image.jpg');
    await image.writeAsBytes(bytes.buffer.asUint8List());

    // Save the captured image to device gallery
    final result = await ImageGallerySaver.saveImage(image.readAsBytesSync());
    print('Image saved to gallery: $result');

    // Reload images to reflect the newly saved image
    _loadImages();
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;

  const FullScreenImagePage({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: EdgeInsets.all(20.0),
          minScale: 0.1,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
