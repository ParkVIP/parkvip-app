import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';


Future getImagePath() async {
    Uint8List? fileBytes;
    late String base64Image;
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
    // if (result != null) {
    //   try {
    //     fileBytes = result!.files.first.bytes; 
    //    // base64Image = base64Encode(fileBytes!);
    //   } catch (err) {
    //     print(err);
    //   }
    // } else {
    //   print('No Image Selected');
    // }
    return result;
}