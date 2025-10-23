import 'dart:html' as html;
import 'dart:typed_data';

Future<Uint8List?> pickWebImage() async {
  final html.FileUploadInputElement input = html.FileUploadInputElement()
    ..accept = 'image/*';
  input.click();
  await input.onChange.first;
  final files = input.files;
  if (files != null && files.isNotEmpty) {
    final file = files.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    final result = reader.result;
    if (result is ByteBuffer) {
      return result.asUint8List(); // Fixed casting: ByteBuffer to Uint8List
    }
  }
  return null;
}
