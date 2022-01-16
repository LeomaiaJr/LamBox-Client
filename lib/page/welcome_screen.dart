import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:lambox/widgets/basic_mic_screen.dart';
import 'package:lambox/page/subscribed_screen.dart';
import 'package:lambox/utils/tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lambox/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:lambox/models/user_data.dart';

int whereAmI = 0;
String userName;
String gender;
String city;
String street;

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text;

  bool read = false;

  void playSound(soundPath) async {
    final player = AudioCache();
    player.play(soundPath);
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void goTonextScreen(String id) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SubscribedScreen(id)));
  }

  void addData(Map map) {
    context.read<UserData>().addUserInfo(map);
  }

  void readIntro() {
    if (!read) {
      read = true;
      speak(kFirstTimeInTheApp);
    }
  }

  @override
  Widget build(BuildContext context) {
    readIntro();
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

  doSomething(String text) async {
    if (text == 'sim' && whereAmI == 0) {
      speak('Para adquirir uma LamBox você primeiro deve fazer um'
          'cadastro em nosso projeto. Vamos começar. Primeiro, diga seu nome completo');
      whereAmI = 1;
    } else if (whereAmI == 1) {
      userName = text;
      whereAmI = 2;
      speak('Agora informe seu gênero');
    } else if (whereAmI == 2) {
      gender = text;
      whereAmI = 3;
      speak(
          'Agora informe seu endereço para receber sua LamBox. Começando pela sua rua.');
    } else if (whereAmI == 3) {
      street = text;
      whereAmI = 4;
      speak('Diga o nome da sua cidade');
    } else if (whereAmI == 4) {
      city = text;
      speak('Para confirmar seu cadastro, confirme suas informações.'
          'Nome, $userName. Gênero, $gender. Rua do endereço, $street. Cidade, $city');
      whereAmI = 5;
    } else if (whereAmI == 5) {
      var _text = text.split(' ');
      if (_text.contains('não') || _text.contains('incorretas')) {
        whereAmI = 1;
        speak('Tudo bem. Vamos fazer de novo. Primeiro, diga seu nome');
      } else if (_text.contains('sim') ||
          _text.contains('estão') ||
          _text.contains('positivo')) {
        speak(
            'Perfeito. Cadastro feito com sucesso. Sua LamBox está a caminho. Informe ao aplicativo quando receber sua LamBox');
        saveUserFirebase();
      }
    }
  }

  saveUserFirebase() async {
    final Firestore _firestore = Firestore.instance;
    String userId =
        _firestore.collection("users").document().documentID.toString();
    print(userId);
    await _firestore.collection('users').document(userId).setData({
      'Name': userName,
      'Gender': gender,
      'Street': street,
      'City': city,
      'Received': false,
      'gateA': false,
      'gateB': false,
    });
    addData({
      'name': userName,
      'gender': gender,
      'street': street,
      'city': city,
      'id': userId,
    });
    goTonextScreen(userId);
  }
}
