import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

final _tts = FlutterTts();

void speak(String text) async {
  final completer = Completer();
  _tts.setCompletionHandler(() => completer.complete());
  _tts.setErrorHandler((err) => completer.completeError(err));
  await _tts.speak(text);
  return completer.future;
}
