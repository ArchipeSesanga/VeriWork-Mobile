import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Uint8List? _webImageBytes;
  String? _mobileImagePath;

  final String firebaseImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/veriwork-database.appspot.com/o/f0e3e68a-d57c-4790-b030-23ef42b2280a_greenp-arrot.jpg?alt=media";

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _mobileImagePath = pickedFile.path;
        });
      }
    }
  }

  ImageProvider<Object> _getProfileImage() {
    if (kIsWeb) {
      if (_webImageBytes != null) {
        return MemoryImage(_webImageBytes!);
      } else {
        return NetworkImage(firebaseImageUrl);
      }
    } else {
      if (_mobileImagePath != null) {
        return FileImage(File(_mobileImagePath!));
      } else {
        return NetworkImage(firebaseImageUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: _getProfileImage(),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _getProfileImage(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Change Picture"),
            ),
          ],
        ),
      ),
    );
  }
}
