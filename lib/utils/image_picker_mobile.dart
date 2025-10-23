import 'package:image_picker/image_picker.dart';

Future<String?> pickMobileImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  return pickedFile?.path;
}
