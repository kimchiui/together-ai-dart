import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:together_ai_sdk/src/common/enum_ai_models.dart';
import 'dart:developer' as developer;
import 'package:together_ai_sdk/src/common/error_handling.dart';
import 'package:together_ai_sdk/src/models/chat_completion.dart';
import 'package:together_ai_sdk/src/models/image_generation.dart';
import 'package:together_ai_sdk/src/models/text_completion.dart';

/// TogetherAISdk provides access to the following methods.
/// - chatCompletion, this is the endpoint to use for chat completion.
/// - textCompletion, this is the endpoint to use for text completion.
///  - embeddings, this is the endpoint to use for embeddings.
/// - imageGeneration, this is the endpoint to use for image generation.
/// - streamResponse, this is the endpoint to use for stream response.
///  When initializing the TogetherAISdk class, you need to provide an API key which you can get from here https://api.together.xyz/settings/api-keys
/// This package depends on Dio package to make HTTP requests.

class TogetherAISdk {
  final String apiKey;
  Dio dio;

  TogetherAISdk(this.apiKey)
      : dio = Dio(BaseOptions(
          baseUrl: 'https://api.together.xyz',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ));

  /// ChatCompletion method is used to chat with the model in a chat based format.
  Future<ChatCompletion> chatCompletion(
    List<Map<String, String>> messages,
    ChatModel model, {
    List<String>? stop,
    int? maxTokens,
    int? temperature,
    int? topP,
    int? topK,
    int? repetitionPenalty,
  }) async {
    try {
      final response = await dio.post(
        '/v1/chat/completions',
        data: {
          'model': model.toString(),
          'stop': stop ?? ['</s>', '[/INST]'],
          'max_tokens': maxTokens ?? 512,
          'temperature': temperature ?? 0.7,
          'top_p': topP ?? 0.7,
          'top_k': topK ?? 50,
          'repetition_penalty': repetitionPenalty ?? 1,
          'messages': messages,
        },
      );

      final data = response.data;
      return ChatCompletion.fromJson(data);
    } on DioException catch (e) {
      developer.log(e.toString());
      final errorResponse = e.response?.data;
      final errorMessage =
          errorResponse?['error']?['message'] ?? 'Unknown error';
      final errorCode = errorResponse?['error']?['code'] ?? 'unknown_error';
      final error = getTogetherAIError(errorCode, errorMessage);
      developer.log('Error: ${error.message}', name: 'together_ai_sdk.name');
      throw error;
    } catch (e) {
      final error = UnknownServerError('An unknown error occurred: $e');
      developer.log('Error: ${error.message}', name: 'together_ai_sdk.name');
      throw error;
    }
  }

  /// VisionChatCompletion method is used to chat with the vision model in a chat based format.

  Future<ChatCompletion> visionChatCompletion(
    List<Map<String, Object>> messages,
    ChatVisionModel model, {
    List<String>? stop,
    int? maxTokens,
    int? temperature,
    int? topP,
    int? topK,
    int? repetitionPenalty,
  }) async {
    try {
      final response = await dio.post(
        '/v1/chat/completions', // Or the appropriate endpoint for vision models
        data: {
          'model': model.toString(),
          'stop': stop ??
              [
                '</s>',
                '[/INST]'
              ], // Adjust stop sequences if needed for vision models
          'max_tokens': maxTokens ?? 512,
          'temperature': temperature ?? 0.7,
          'top_p': topP ?? 0.7,
          'top_k': topK ?? 50,
          'repetition_penalty': repetitionPenalty ?? 1,
          'messages': messages,
        },
      );

      final data = response.data;
      return ChatCompletion.fromJson(data);
    } on DioException catch (e) {
      developer.log(e.toString());
      final errorResponse = e.response?.data;
      final errorMessage =
          errorResponse?['error']?['message'] ?? 'Unknown error';
      final errorCode = errorResponse?['error']?['code'] ?? 'unknown_error';
      final error = getTogetherAIError(errorCode, errorMessage);
      developer.log('Error: ${error.message}', name: 'together_ai_sdk.name');
      throw error;
    } catch (e) {
      final error = UnknownServerError('An unknown error occurred: $e');
      developer.log('Error: ${error.message}', name: 'together_ai_sdk.name');
      throw error;
    }
  }

  /// Text Completion method is used to complete text based on the prompt provided.
  ///
  Future<TextCompletion> textCompletion(
    String prompt,
    LanguageModel model, {
    int? maxTokens,
    List<String>? stop,
    int? temperature,
    int? topP,
    int? topK,
    int? repetitionPenalty,
  }) async {
    try {
      //For more information on the parameters, visit https://docs.together.ai/reference/completions
      final response = await dio.post('/v1/completions', data: {
        'model': model.toString(),
        'prompt': '<s>[INST] $prompt [/INST]',
        'max_tokens': maxTokens ?? 512,
        'stop': stop ?? ['</s>', '[/INST]'],
        'temperature': temperature ?? 0.7,
        'top_p': topP ?? 0.7,
        'top_k': topK ?? 50,
        'repetition_penalty': repetitionPenalty ?? 1,
      });
      final data = response.data;
      return TextCompletion.fromJson(data);
    } on DioException catch (e) {
      developer.log(e.toString());
      final errorResponse = e.response?.data;
      final errorMessage =
          errorResponse?['error']?['message'] ?? 'Unknown error';
      final errorCode = errorResponse?['error']?['code'] ?? 'unknown_error';
      final error = getTogetherAIError(errorCode, errorMessage);
      developer.log('Error: ${error.message}', name: 'together_ai_sdk.name');
      throw error;
    } catch (e) {
      final error = UnknownServerError('An unknown error occurred: $e');
      developer.log('Error: ${error.message}', name: 'together_ai_sdk.name');
      throw error;
    }
  }

  /// This method converts your input into embeddings.

  Future<dynamic> embeddings(String input, String embeddModel) async {
    try {
      //For more information on the parameters, visit https://docs.together.ai/reference/embeddings
      final response = await dio.post('/v1/embeddings', data: {
        'model': embeddModel,
        'input': input,
      });
      return response.data;
    } on DioException catch (e) {
      developer.log(e.toString());
      final errorResponse = e.response?.data;
      final errorMessage = errorResponse['error']['message'];
      final errorCode = errorResponse['error']['code'];
      final error = getTogetherAIError(errorCode, errorMessage).message;
      developer.log('Error: $error', name: 'together_ai_sdk.name');
      return null;
    } catch (e) {
      final error = UnknownServerError('An unknown error occurred.');
      developer.log('Error: $error', name: 'together_ai_sdk.name');
      return null;
    }
  }

  ///Use for generating images based on the prompt provided.

  Future<ImageGenerationResponse?> imageGeneration(
    String prompt, {
    required ImageModel imageModel,
    int n = 1,
    int steps = 10,
  }) async {
    //TODO 4: Add link for more information on the parameters
    try {
      final response = await dio.post('/v1/images/generations', data: {
        'model': imageModel.toString(),
        'prompt': prompt,
        'n': n,
        'steps': steps,
      });
      final data = response.data;
      developer.log('Data: ${data}', name: 'together_ai_sdk.name');
      return ImageGenerationResponse.fromJson(data);
    } on DioException catch (e) {
      developer.log(e.toString());
      final errorResponse = e.response?.data;
      final errorMessage = errorResponse['error']['message'];
      final errorCode = errorResponse['error']['code'];
      final error = getTogetherAIError(errorCode, errorMessage).message;
      developer.log('Error: $error', name: 'together_ai_sdk.name');
      return null;
    } catch (e) {
      final error = UnknownServerError('An unknown error occurred.');
      developer.log('Error: $error', name: 'together_ai_sdk.name');
      return null;
    }
  }

  // Use if you want to stream your responses from the API, this returns the raw JSON response.

  Future<dynamic> streamResponse(
    List<Map<String, String>> messages,
    ChatModel model, {
    int? maxTokens,
    List<String>? stop,
    int? temperature,
    int? topP,
    int? topK,
    int? repetitionPenalty,
  }) async {
    try {
      final response = await dio.post(
        '/v1/chat/completions',
        data: {
          'model': model.toString(),
          'messages': messages,
          'max_tokens': maxTokens ?? 128,
          'stop': stop ?? ['\n\n'],
          'temperature': temperature ?? 0.7,
          'top_p': topP ?? 0.7,
          'top_k': topK ?? 50,
          'repetition_penalty': repetitionPenalty ?? 1,
          'stream': true, // Use 'stream' instead of 'stream_tokens'
        },
      );
      return response.data;
    } on DioException catch (e) {
      developer.log(e.toString());
      final errorResponse = e.response?.data;
      final errorMessage = errorResponse['error']['message'];
      final errorCode = errorResponse['error']['code'];
      final error = getTogetherAIError(errorCode, errorMessage).message;
      developer.log('Error: $error', name: 'together_ai_sdk.name');
      throw error;
    } catch (e) {
      final error = UnknownServerError('An unknown error occurred.');
      developer.log('Error: $error', name: 'together_ai_sdk.name');
      return null;
    }
  }

  //TODO 3: Implement the methods for fine-tuning models

  //   Future<Response> startFineTuneInstance(String modelName) async {
  //   try {
  //     final response = await _dio.post(
  //       '/instances/start',
  //       queryParameters: {'model': modelName},
  //     );
  //     return response;
  //   } catch (e) {
  //     throw Exception('Failed to start fine-tune instance: $e');
  //   }
  // }

  // Future<Response> stopFineTuneInstance(String modelName) async {
  //   try {
  //     final response = await _dio.post(
  //       '/instances/stop',
  //       queryParameters: {'model': modelName},
  //     );
  //     return response;
  //   } catch (e) {
  //     throw Exception('Failed to stop fine-tune instance: $e');
  //   }
  // }

  // Future<Response> listRunningInstances() async {
  //   try {
  //     final response = await _dio.get('/instances');
  //     return response;
  //   } catch (e) {
  //     throw Exception('Failed to list running instances: $e');
  //   }
  // }
}

Future<String> imageToBase64(String imagePath) async {
  File imageFile = File(imagePath);
  List<int> imageBytes = await imageFile.readAsBytes();
  String base64Image = base64Encode(imageBytes);

  return "data:image/jpeg;base64,$base64Image";
}

// Convert the image url to a b64 encoded image data url
Future<String?> imageUrlToBase64(String imageUrl) async {
    final dio = Dio();

    try {
    // Fetch the image data from the URL
    final response = await dio.get(imageUrl, options: Options(responseType: ResponseType.bytes));
  
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

//Deprecated code

// Future<ChatCompletion?> chatCompletion(
//   List<Map<String, String>> messages,
//   ChatModel model, {
//   List<String>? stop,
//   int? maxTokens,
//   int? temperature,
//   int? topP,
//   int? topK,
//   int? repetitionPenalty,
// }) async {
//   try {
//     final response = await dio.post(
//       '/v1/chat/completions',
//       //Note that if you do not pass parameters, the default values will be used. For more information on the default values, visit https://docs.together.ai/reference/chat-completions
//       data: {
//         'model': model.toString(),
//         'stop': stop ?? ['</s>', '[/INST]'],
//         'max_tokens': maxTokens ?? 512,
//         'temperature': temperature ?? 0.7,
//         'top_p': topP ?? 0.7,
//         'top_k': topK ?? 50,
//         'repetition_penalty': repetitionPenalty ?? 1,
//         'messages': messages,
//       },
//     );

//     final data = response.data;
//     return ChatCompletion.fromJson(data);
//   } on DioException catch (e) {
//     developer.log(e.toString());
//     final errorResponse = e.response?.data;
//     final errorMessage = errorResponse['error']['message'];
//     final errorCode = errorResponse['error']['code'];
//     final error = getTogetherAIError(errorCode, errorMessage).message;
//     developer.log('Error: $error', name: 'together_ai_sdk.name');
//     return null;
//   } catch (e) {
//     final error = UnknownServerError('An unknown error occurred.');
//     developer.log('Error: $error', name: 'together_ai_sdk.name');
//     return null;
//   }
// }

// Future<TextCompletion?> textCompletion(String prompt, LanguageModel model,
//     {int? maxTokens,
//     List<String>? stop,
//     int? temperature,
//     int? topP,
//     int? topK,
//     int? repetitionPenalty}) async {
//   try {
//     //For more information on the parameters, visit https://docs.together.ai/reference/completions
//     final response = await dio.post('/v1/completions', data: {
//       'model': model.toString(),
//       'prompt': '<s>[INST] $prompt [/INST]',
//       'max_tokens': maxTokens ?? 512,
//       'stop': stop ?? ['</s>', '[/INST]'],
//       'temperature': temperature ?? 0.7,
//       'top_p': topP ?? 0.7,
//       'top_k': topK ?? 50,
//       'repetition_penalty': repetitionPenalty ?? 1,
//     });
//     final data = response.data;
//     return TextCompletion.fromJson(data);
//   } on DioException catch (e) {
//     developer.log(e.toString());
//     final errorResponse = e.response?.data;
//     final errorMessage = errorResponse['error']['message'];
//     final errorCode = errorResponse['error']['code'];
//     final error = getTogetherAIError(errorCode, errorMessage).message;
//     developer.log('Error: $error', name: 'together_ai_sdk.name');
//     return null;
//   } catch (e) {
//     final error = UnknownServerError('An unknown error occurred.');
//     developer.log('Error: $error', name: 'together_ai_sdk.name');
//     return null;
//   }
// }
