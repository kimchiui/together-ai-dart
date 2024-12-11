// Image Generation Model

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
}
