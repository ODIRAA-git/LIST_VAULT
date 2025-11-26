import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    return await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
  }

  Future<String?> startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _isListening = true;
        String recognizedText = '';

        await _speech.listen(
          onResult: (result) {
            recognizedText = result.recognizedWords;
          },
          listenFor: const Duration(seconds: 5),
          pauseFor: const Duration(seconds: 3),
        );

        // Wait for recognition to complete
        await Future.delayed(const Duration(seconds: 6));
        _isListening = false;

        return recognizedText.isNotEmpty ? recognizedText : null;
      }
    }
    return null;
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  void dispose() {
    _speech.cancel();
  }
}
