import 'dart:io';

import 'package:dio/dio.dart';

class CloudinaryService {
  final Dio _dio = Dio();

  Future<String> uploadImage(File file) async {
    const cloudName = 'debgaimcw';
    const uploadPreset = 'loomflow';

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': uploadPreset,
      });

      print('Uploading to Cloudinary: $file');
      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      print('Cloudinary response status: ${response.statusCode}');
      print('Cloudinary response: ${response.data}');

      if (response.statusCode == 200 && response.data['secure_url'] != null) {
        return response.data['secure_url'] as String;
      } else {
        throw Exception('Invalid response from Cloudinary: ${response.data}');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      rethrow;
    }
  }
}
