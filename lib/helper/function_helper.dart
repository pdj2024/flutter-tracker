import 'dart:io';
import 'dart:ui';

import 'package:image_picker/image_picker.dart';

class FunctionHelper {
  static Future<XFile?> pickImageFromGallery() async {
    ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    return picked;
  }

  static Future<XFile?> pickImageFromCamera() async {
    ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.camera);
    return picked;
  }

  // Generator warna gradient otomatis
  static List<List<Color>> generateGradients(int count) {
    final List<List<Color>> baseGradients = [
      [Color(0xff10bddc), Color(0xff2fd5f2)], // Biru
      [Color(0xff6a11cb), Color(0xff2575fc)], // Ungu-Biru
      [Color(0xffff6b6b), Color(0xffee5a6f)], // Merah
      [Color(0xffF093FB), Color(0xffF5576C)], // Pink
      [Color(0xff4facfe), Color(0xff00f2fe)], // Cyan
      [Color(0xff43e97b), Color(0xff38f9d7)], // Hijau
      [Color(0xfffa709a), Color(0xfffee140)], // Pink-Yellow
      [Color(0xff30cfd0), Color(0xff330867)], // Cyan-Purple
      [Color(0xffa8edea), Color(0xfffed6e3)], // Mint-Pink
      [Color(0xffff9a56), Color(0xffff6a88)], // Orange-Red
    ];

    // Jika jumlah fitur lebih dari base gradients, akan diulang dari awal
    List<List<Color>> result = [];
    for (int i = 0; i < count; i++) {
      result.add(baseGradients[i % baseGradients.length]);
    }
    return result;
  }
}
