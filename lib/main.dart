import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Loading Images through gallery
  File? _image;
  final _picker = ImagePicker();

  pickImage() async {
    //ImageSource.gallery can be changed to ImageSource.camera to use the camera directly
    //and avoid the use of the gallery
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.blue,
        actions: <IconButton>[
          IconButton(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
            icon: Row(
              children: [
                //Veriwork Logo
                CircleAvatar(
                  backgroundImage: AssetImage('images/emptyProfile.png'),
                  radius: 25,
                ),

                //Spacing between Veriwork Logo and Logout Icon
                SizedBox(width: 80),

                //Logout Icon
                const Icon(Icons.logout, size: 30, color: Colors.white),

                //Spacing between Logo and Avatar
                SizedBox(width: 15),

                //Avatar Icon
                CircleAvatar(
                  backgroundImage: AssetImage('images/emptyProfile.png'),
                  radius: 20,
                ),
              ],
            ),
            onPressed: () {
              // Perform an action when the settings icon is pressed
            },
          ),
        ],
      ),

      //Space above "Take Photo" text
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 15),
        child: Column(
          children: [
            Center(
              child: Text(
                "Take Photo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),

            //Text for selfie verification
            Text(
              "Take a clear selfie for verification",
              style: TextStyle(fontSize: 17),
            ),

            //Profile Photo Background Widget
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 30),
              child: Container(
                width: 500,
                height: 350,
                color: const Color.fromARGB(255, 85, 142, 189),
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: ClipOval(
                    child: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 145, 155, 160),
                      child:
                          _image == null
                              ? Icon(Icons.person, size: 200)
                              : Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),

            //Button to take a selfie
            MaterialButton(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(110, 25, 110, 25),
                child: const Text(
                  "Capture Selfie",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              onPressed: () {
                pickImage();
              },
            ),

            //Submit Button
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: MaterialButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(115, 25, 110, 25),
                  child: const Text(
                    "Submit Selfie",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
