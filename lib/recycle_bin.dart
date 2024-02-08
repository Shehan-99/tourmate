import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class RecycleBinPage extends StatefulWidget {
  const RecycleBinPage({Key? key}) : super(key: key);

  @override
  _RecycleBinPageState createState() => _RecycleBinPageState();
}

class _RecycleBinPageState extends State<RecycleBinPage> {
  List<File> _deletedImages = [];

  @override
  void initState() {
    super.initState();
    _loadDeletedImages();
  }

  Future<void> _loadDeletedImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recycleBinDir = Directory('${appDir.path}/RecycleBin');
    if (await recycleBinDir.exists()) {
      final files = recycleBinDir.listSync();
      setState(() {
        _deletedImages = files.whereType<File>().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recycle Bin'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _deletedImages.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // You can implement any action you want when the image is tapped
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(_deletedImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
