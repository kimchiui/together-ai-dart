import 'package:together_ai_sdk/src/models/chat_completion.dart';
import 'package:together_ai_sdk/together_ai_sdk.dart';

abstract class ConversationMemory {
  List<Map<String, String>> getMessages();
  void addMessage(Message message);
  void clear();
}

// This class is used to store the conversation messages in memory, there is no limit to the number of messages that can be stored.
class ConversationBufferMemory implements ConversationMemory {
  final List<Message> _messages = [];

  @override
  List<Map<String, String>> getMessages() {
    return _messages
        .map((message) => {
              'role': message.role,
              'content': message.content,
            })
        .toList();
  }

  @override
  void addMessage(Message message) {
    _messages.add(message);
  }

  @override
  void clear() {
    _messages.clear();
  }
}

// This class is used to store the conversation messages in memory, with a limit to the number of messages that can be stored.
// If you decide to store more messages than the window size, the oldest messages will be removed.
// The window size is set when initializing the class, this size is the maximum number of messages that can be stored.

class ConversationBufferWindowMemory implements ConversationMemory {
  final int _windowSize;
  final List<Message> _messages = [];

  ConversationBufferWindowMemory(this._windowSize);

  @override
  List<Map<String, String>> getMessages() {
    if (_messages.length <= _windowSize) {
      return _messages
          .map((message) => {
                'role': message.role,
                'content': message.content,
              })
          .toList();
    }
    return _messages
        .sublist(_messages.length - _windowSize)
        .map((message) => {
              'role': message.role,
              'content': message.content,
            })
        .toList();
  }

  @override
  void addMessage(Message message) {
    _messages.add(message);
    if (_messages.length > _windowSize) {
      _messages.removeAt(0); // Remove the oldest message
    }
  }

  @override
  void clear() {
    _messages.clear();
  }
}

class ConversationSummaryBufferMemory implements ConversationMemory {
  final int _windowSize;
  String _currentSummary = "";
  final List<Map<String, String>> _messages = [];
  final TogetherAISdk _llm;
  final ChatModel _model;

  ConversationSummaryBufferMemory(
      this._windowSize, this._currentSummary, this._llm, this._model);

  // Getter for current summary
  String getCurrentSummary() {
    return _currentSummary;
  }

  // Get messages within the window size
  @override
  List<Map<String, String>> getMessages() {
    if (_messages.length <= _windowSize) {
      return _messages;
    }
    return _messages.sublist(_messages.length - _windowSize);
  }

  // Add a new message to the conversation
  @override
  Future<void> addMessage(Message message) async {
    Map<String, String> messageMap = {
      'role': message.role,
      'content': message.content,
    };
    _messages.add(messageMap);

    if (_messages.length > _windowSize) {
      await _updateSummary();
    }
  }

  // Clear all messages and summary
  @override
  void clear() {
    _messages.clear();
    _currentSummary = "";
  }

  // Private method to update the summary
  Future<void> _updateSummary() async {
    final messagesToSummarize =
        _messages.sublist(0, _messages.length - _windowSize);
    final promptMessages = [
      {
        'role': 'system',
        'content': 'You are a helpful assistant that summarizes conversations.'
      },
      {
        'role': 'user',
        'content': '''
Please summarize the following conversation:

${messagesToSummarize.map((m) => "${m['role']}: ${m['content']}").join('\n')}

Current summary: $_currentSummary
'''
      }
    ];

    final completion = await _llm.chatCompletion(promptMessages, _model);

    // Update summary and remove summarized messages
    if (completion.choices.isNotEmpty) {
      _currentSummary = completion.choices[0].message.content;
      _messages.removeRange(0, _messages.length - _windowSize);
    }
  }
}
