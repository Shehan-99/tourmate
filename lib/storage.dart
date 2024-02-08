import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'recycle_bin.dart'; // Import the Recycle Bin page

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
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
        child: Image.file(File(imagePath)),
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
  String _selectedFilter = 'All';

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

  List<DropdownMenuItem<String>> _buildFilterItems() {
    return [
      const DropdownMenuItem(
        value: 'All',
        child: Text('All'),
      ),
      const DropdownMenuItem(
        value: 'Today',
        child: Text('Today'),
      ),
      const DropdownMenuItem(
        value: 'This Week',
        child: Text('This Week'),
      ),
      const DropdownMenuItem(
        value: 'This Month',
        child: Text('This Month'),
      ),
      const DropdownMenuItem(
        value: 'This Year',
        child: Text('This Year'),
      ),
    ];
  }

  void _onFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedFilter = value;
        // You can implement the logic to filter images based on the selected filter here
      });
    }
  }

  Future<void> _deleteImage(int index) async {
    // Move the deleted image to the Recycle Bin
    String imagePath = _images[index].path;
    String fileName = imagePath.split('/').last;
    final appDir = await getApplicationDocumentsDirectory();
    final recycleBinDir = Directory('${appDir.path}/RecycleBin');
    if (!await recycleBinDir.exists()) {
      await recycleBinDir.create();
    }
    await _images[index].copy('${recycleBinDir.path}/$fileName');
    await _images[index].delete();
    _images.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the sidebar view (Drawer)
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Saved Image',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: _selectedFilter,
            items: _buildFilterItems(),
            onChanged: _onFilterChanged,
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _images.length,
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImagePage(
                        imagePath: _images[index].path,
                      ),
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
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteImage(index),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

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
            ).then((_) {
              // Open the sidebar view (Drawer) after returning from StoragePage
              Scaffold.of(context).openEndDrawer();
            });
          },
          child: Text('Go to Storage Page'),
        ),
      ),
    );
  }
}
