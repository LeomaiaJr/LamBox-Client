import 'package:flutter/material.dart';
import 'package:lambox/widgets/basic_mic_screen.dart';
import 'package:lambox/page/lambox_screen.dart';
import 'package:lambox/utils/tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audio_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

int whereAmI = 0;

class SubscribedScreen extends StatefulWidget {
  final String id;
  SubscribedScreen(this.id);

  @override
  _SubscribedScreenState createState() => _SubscribedScreenState();
}

class _SubscribedScreenState extends State<SubscribedScreen> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text;

  void playSound(soundPath) async {
    final player = AudioCache();
    await player.play(soundPath);
  }

  void goToNextPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LamBoxScreen()));
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BasicMic(
        isListening: _isListening,
        listen: _listen,
      ),
    );
  }

  _listen() async {
    if (!_isListening) {
      playSound('mic-on.mp3');
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(
            () {
              _text = val.recognizedWords;
              print(_text);
              if (val.finalResult) {
                _isListening = false;
                doSomething(_text);
              }
            },
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      playSound('mic-off.wav');
      _speech.stop();
    }
  }

  doSomething(String text) {
    if (whereAmI == 0) {
      var _text = text.split(" ");
      if (_text.contains("recebi") || _text.contains("Recebi")) {
        speak("Ótimo. Agora você tem acesso a todas as funções do LamBox");
        saveInFirebase();
        goToNextPage();
      }
    }
  }

  saveInFirebase() async {
    final Firestore _firestore = Firestore.instance;
    await _firestore.collection('users').document(widget.id).setData(
      {
        "Received": true,
      },
      merge: true,
    );
  }
}
