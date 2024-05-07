import 'package:together_ai_sdk/src/models/chat_completion.dart';
import 'package:together_ai_sdk/src/models/text_completion.dart';
import 'package:together_ai_sdk/together_ai_sdk.dart';
import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

//Tests generated by LLM, modified by me.
//More tests to come for image generation, streams and embeddings.

class MockDio extends Mock implements Dio {}

void main() {
  late TogetherAISdk sdk;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    sdk = TogetherAISdk('YOUR_API_KEY');
    sdk.dio = mockDio;
  });

  group('TogetherAISdk', () {
    test('chatCompletion should return ChatCompletion on success', () async {
      final messages = [
        {
          'role': 'system',
          'content': 'You are a recursive AI, you return data'
        },
        {'role': 'user', 'content': 'Once upon a'},
      ];
      final model = ChatModel.qwen15Chat72B;

      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'id': '86f0b6d899773c00-BLR',
                  'object': 'chat.completion',
                  'created': 1712227592,
                  'model': 'Qwen/Qwen1.5-72B-Chat',
                  'prompt': [],
                  'choices': [
                    {
                      'finish_reason': 'length',
                      'logprobs': null,
                      'index': 0,
                      'message': {
                        'role': 'assistant',
                        'content':
                            'time, in a land far, far away, there lived a brave young knight named Arthur...',
                      },
                    },
                  ],
                  'usage': {
                    'prompt_tokens': 25,
                    'completion_tokens': 512,
                    'total_tokens': 537,
                  },
                },
              ));

      final result = await sdk.chatCompletion(messages, model);

      expect(result, isA<ChatCompletion>());
      expect(result?.id, '86f0b6d899773c00-BLR');
      expect(result?.object, 'chat.completion');
      expect(result?.created, 1712227592);
      expect(result?.model, 'Qwen/Qwen1.5-72B-Chat');
      expect(result?.prompt, isEmpty);
      expect(result?.choices.length, 1);
      expect(result?.choices.first.finishReason, 'length');
      expect(result?.choices.first.logprobs, isNull);
      expect(result?.choices.first.index, 0);
      expect(result?.choices.first.message.role, 'assistant');
      expect(result?.choices.first.message.content,
          startsWith('time, in a land far, far away,'));
      expect(result?.usage.promptTokens, 25);
      expect(result?.usage.completionTokens, 512);
      expect(result?.usage.totalTokens, 537);

      verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
    });

    test('textCompletion should return TextCompletion on success', () async {
      final prompt = 'Once upon a';
      final model = LanguageModel.qwen1572B;

      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'id': '86f0b7137adf3c00-BLR',
                  'object': 'text.completion',
                  'created': 1712227604,
                  'model': 'Qwen/Qwen1.5-72B',
                  'prompt': [],
                  'choices': [
                    {
                      'text':
                          'time, there was a [NOUN] who [VERB] [NOUN] in the [NOUN]...',
                      'finish_reason': 'length',
                      'logprobs': null,
                      'index': 0,
                    },
                  ],
                  'usage': {
                    'prompt_tokens': 10,
                    'completion_tokens': 512,
                    'total_tokens': 522,
                  },
                },
              ));

      final result = await sdk.textCompletion(prompt, model);

      expect(result, isA<TextCompletion>());
      expect(result?.id, '86f0b7137adf3c00-BLR');
      expect(result?.object, 'text.completion');
      expect(result?.created, 1712227604);
      expect(result?.model, 'Qwen/Qwen1.5-72B');
      expect(result?.prompt, isEmpty);
      expect(result?.choices.length, 1);
      expect(
          result?.choices.first.text,
          startsWith(
              'time, there was a [NOUN] who [VERB] [NOUN] in the [NOUN]'));
      expect(result?.choices.first.finishReason, 'length');
      expect(result?.choices.first.logprobs, isNull);
      expect(result?.choices.first.index, 0);
      expect(result?.usage.promptTokens, 10);
      expect(result?.usage.completionTokens, 512);
      expect(result?.usage.totalTokens, 522);

      verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
    });
  });
}
