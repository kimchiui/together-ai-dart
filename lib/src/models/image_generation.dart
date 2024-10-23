// Image Generation Model

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class ImageGenerationResponse {
  final String id;
  final String model;
  final String object;
  final List<ImageData> data;

  ImageGenerationResponse({
    required this.id,
    required this.model,
    required this.object,
    required this.data,
  });

  factory ImageGenerationResponse.fromJson(Map<String, dynamic> json) {
    return ImageGenerationResponse(
      id: json['id'],
      model: json['model'],
      object: json['object'],
      data:
          List<ImageData>.from(json['data'].map((x) => ImageData.fromJson(x))),
    );
  }

  @override
  String toString() {
    return 'ImageGenerationResponse(id: $id, model: $model, object: $object, data: $data)';
  }
}

class ImageData {
  final int index;
  //final String b64Json;
  final String url;

  ImageData({
    required this.index,
    //required this.b64Json,
    required this.url,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      index: json['index'],
      //b64Json: json['b64_json'],
      url: json["url"],
    );
  }

  @override
  String toString() {
    //return 'ImageData(index: $index, b64Json: $b64Json)';
    return 'ImageData(index: $index, url: $url)';
  }

  // Convert the image url to a b64 encoded image data url
  Future<String?> toB64DataUrl() async {
      final dio = Dio();
  
      try {
      // Fetch the image data from the URL
      final response = await dio.get(url, options: Options(responseType: ResponseType.bytes));
    
      if (response.statusCode == 200) {
        // Convert the image bytes to Base64
        Uint8List imageBytes = Uint8List.fromList(response.data);
        String base64Image = base64Encode(imageBytes);
      
        // Construct the Data URL (assuming JPEG format)
        String dataUrl = 'data:image/jpeg;base64,$base64Image';
        //print('Data URL: $dataUrl');
        return dataUrl;
      } else {
        print('Failed to load image. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }
}
