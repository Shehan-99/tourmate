import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tourmate/home.dart';

List<CameraDescription>? cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Color.fromARGB(255, 78, 224, 217)),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
