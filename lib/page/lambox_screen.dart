import 'package:audioplayers/audio_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lambox/page/help_screen.dart';
import 'package:lambox/utils/tts.dart';
import 'package:lambox/widgets/basic_mic_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lambox/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:lambox/models/user_data.dart';
import 'package:time/time.dart';

class LamBoxScreen extends StatefulWidget {
  @override
  _LamBoxScreenState createState() => _LamBoxScreenState();
}

class _LamBoxScreenState extends State<LamBoxScreen> {
  bool medicalRecordIsDone = true;
  bool medicalAppointmentIsDone = false;

  var userData = {};
  Map<String, dynamic> medicalRecord = {};
  List docsId = [];
  List pharmId = [];
  int counter = 0;
  bool _isListening = false;
  String _text;
  stt.SpeechToText _speech;
  int docIndex;
  int pharmIndex;
  String medicalAppointment;

  bool read = false;

  void readIntro() {
    if (!read) {
      read = true;
      speak(kLamboxSub);
    }
  }

  void playSound(soundPath) async {
    final player = AudioCache();
    player.play(soundPath);
  }

  Future<String> _calcDistance(double lat, double lng) async {
    Position position;
    String metricUnit = ' metros';
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    double distance = Geolocator.distanceBetween(
        position.latitude, position.longitude, lat, lng);
    print(distance);
    if (distance > 1000) {
      distance = distance / 1000;
      metricUnit = ' quilômetros';
    }
    String finalDistance = distance.toStringAsFixed(2);
    return finalDistance + metricUnit;
  }

  void updateMedicalRecord(String key, String value) {
    medicalRecord.addAll({key: value});
  }

  // ignore: missing_return
  String toBloodType(String blood) {
    if (blood.contains('positivo')) {
      return blood.replaceAll(' positivo', "+");
    }
    if (blood.contains('negativo')) {
      return blood.replaceAll(' negativo', "-");
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    medicalRecord = {
      'name': 'Arthur',
      'gender': 'masculino',
      'birthday': '08/12/2003',
      'bloodType': 'A+',
      'height': '160 cm e 60kg',
      'alergies': 'Mel',
    };
    readIntro();
    userData = {
      'name': 'Arthur',
      'gender': 'masculino',
      'street': 'Rua pedro Moreira da Costa',
      'city': 'Santa Rita do Sapucaí',
      'id': 'cgORuMpYFUK5ea3T2B0o',
      'birthday': '08/12/2003',
      'bloodType': 'A+',
      'phoneNumber': '987654346',
      'height': '160 cm e 60kg',
      'alergies': 'Mel',
    };

    return Scaffold(
      body: BasicMic(
        help: goToScreen,
        isListening: _isListening,
        listen: _listen,
      ),
    );
  }

  goToScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpScreen(),
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
    print(counter);
    if (counter == 0 && (text == 'sim' || text == 'ficha médica')) {
      updateMedicalRecord('name', userData['name']);
      updateMedicalRecord('gender', userData['gender']);
      speak(
          "Vamos começar. Primeiro diga sua data de nascimento nesse formato. Dia. Mês. Ano");
      counter = 1;
    } else if (counter == 1 && text != '') {
      String birthday = text;
      birthday.replaceAll(RegExp(' +'), '/');
      updateMedicalRecord('birthday', birthday);
      counter = 2;
      speak('Agora, diga sua altura em centímetros, e seu peso em kilogramas');
    } else if (counter == 2 && text != '') {
      counter = 3;
      updateMedicalRecord('height', text);
      speak('Agora informe seu tipo sanguíneo.');
    } else if (counter == 3 && text != '') {
      counter = 4;
      String bloodType = toBloodType(text);
      updateMedicalRecord('bloodType', bloodType);
      speak('Agora informe alguma alergia que você tem.');
    } else if (counter == 4 && text != '') {
      counter = 5;
      updateMedicalRecord('alergies', text);
      speak('Agora informe um número para ser seu contato de emergência.');
    } else if (counter == 5 && text != '') {
      updateMedicalRecord('phoneNumber', text);
      speak(
          'Pronto, sua página de emergência está pronta! Caso precise ativá-la, toque e segure no meio da tela do seu celular.');
      context.read<UserData>().updateMedicalRecord(medicalRecord);
      counter = 0;
      medicalRecordIsDone = true;
    } else if (counter == 0 && text == 'não') {
      speak('Tudo bem!');
    }
    if (counter == 0 && text == 'ajuda') {
      speak(kLamboxSub);
    }
    if (counter == 0 && text == 'médicos' && medicalRecordIsDone) {
      speak('Após ouvir todas as opções, informe a opção de médico desejada.');
      Future.delayed(const Duration(milliseconds: 3500), () async {
        final Firestore _firestore = Firestore.instance;
        QuerySnapshot query =
            await _firestore.collection("Doctors").getDocuments();
        var docs = query.documents;
        var doctorsTimes = 1;
        for (var x = 0; x < docs.length; x++) {
          if (docs[x].data['name'] != '') {
            var doctor = docs[x].data;
            docsId.add(docs[x].documentID);
            String distance = await _calcDistance(doctor['lat'], doctor['lng']);
            speak('Opção $doctorsTimes.'
                'O Doutor ${doctor['name']} é especialista em ${doctor['expertise']}. Ele trabalha no consultório ${doctor['clinic']}, na rua ${doctor['street']}'
                'que fica a $distance da sua localização atual.');
            doctorsTimes++;
          }
          counter = 102;
        }
      });
    } else if (counter == 102 && text != '') {
      if (text.contains('1')) {
        docIndex = 1;
      } else if (text.contains('2')) {
        docIndex = 2;
      } else {
        docIndex = 1;
      }
      speak('Que horas você deseja marcar a consulta?');
      counter = 103;
    } else if (counter == 103 && text != '') {
      medicalAppointment = text;
      updateMedicalRecord('appointment', text);
      final Firestore _firestore = Firestore.instance;
      await _firestore
          .collection('Doctors')
          .document(docsId[docIndex - 1])
          .collection('pacientes')
          .document()
          .setData(medicalRecord);
      speak(
          'Consulta marcada com sucesso, caso precise, diga consulta, para lembrar a hora da consulta e para saber o endereço');
      counter = 0;
      medicalAppointmentIsDone = true;
    } else if (counter == 0 && text == 'médicos' && !medicalRecordIsDone) {
      counter = 0;
      speak(
          'Você ainda não fez a sua ficha médica, diga ficha médica para completar sua ficha médica');
    }
    if (text == 'cancelar') {
      speak('Tudo bem');
      counter = 0;
    }
    if (text == '') {
      speak('Não entendi, diga de novo');
    }
    if (counter == 0 && text == 'consulta') {
      print(medicalAppointment);
      final Firestore _firestore = Firestore.instance;
      DocumentSnapshot rawDocument = await _firestore
          .collection('Doctors')
          .document(docsId[docIndex - 1])
          .get();
      var document = rawDocument.data;
      speak(
        "A sua consulta com o Doutor ${document['name']}, será às $medicalAppointment. "
        "Consultório ${document['clinic']} na rua ${document['street']}",
      );
    }
    if (counter == 0 && text == 'farmácia') {
      speak(
          'Após ouvir todas as opções, informe a opção de farmácia desejada.');
      Future.delayed(const Duration(milliseconds: 3500), () async {
        final Firestore _firestore = Firestore.instance;
        QuerySnapshot query =
            await _firestore.collection("Pharmacies").getDocuments();
        var docs = query.documents;
        var pharmacyTimes = 1;
        for (var x = 0; x < docs.length; x++) {
          if (docs[x].data['name'] != '') {
            var doctor = docs[x].data;
            pharmId.add(docs[x].documentID);
            String distance = await _calcDistance(doctor['lat'], doctor['lng']);
            speak(
              'Opção $pharmacyTimes.'
              'A ${doctor['name']}, localizada na rua ${doctor['street']},'
              'que fica a $distance da sua localização atual.',
            );
            pharmacyTimes++;
          }
        }
        counter = 50;
      });
    } else if (counter == 50 && text != '') {
      if (text.contains('1')) {
        pharmIndex = 1;
      } else if (text.contains('2')) {
        pharmIndex = 2;
      } else {
        pharmIndex = 1;
      }
      print(pharmIndex);
      print(docIndex);
      print(pharmId);
      print(docsId);
      final Firestore _firestore = Firestore.instance;
      QuerySnapshot rawDocument = await _firestore
          .collection('Doctors')
          .document(docsId[docIndex - 1])
          .collection('pacientes')
          .where('name', isEqualTo: userData['name'])
          .limit(1)
          .getDocuments();
      var document = rawDocument.documents[0].data;
      await _firestore
          .collection('Pharmacies')
          .document(pharmId[pharmIndex - 1])
          .collection('clientes')
          .document()
          .setData({
        'name': userData['name'],
        'gender': userData['gender'],
        'pill1': document['pill1'],
        'pill2': document['pill2']
      });

      speak('Entendido, caso precise lembrar, diga minha farmácia.');
      counter = 0;
    }
    if (counter == 0 && text == 'minha farmácia') {
      final Firestore _firestore = Firestore.instance;
      DocumentSnapshot rawDocument = await _firestore
          .collection('Pharmacies')
          .document(pharmId[pharmIndex - 1])
          .get();
      var document = rawDocument.data;
      speak(
        "A  ${document['name']}, fica na rua ${document['street']}",
      );
    }
    if (counter == 0 && text == 'remédios' && medicalAppointmentIsDone) {
      final Firestore _firestore = Firestore.instance;
      QuerySnapshot rawDocument = await _firestore
          .collection('Doctors')
          .document(docsId[docIndex - 1])
          .collection('pacientes')
          .where('name', isEqualTo: userData['name'])
          .limit(1)
          .getDocuments();
      var document = rawDocument.documents[0].data;
      if (document['pill1'] == null) {
        speak('Você ainda não tem nenhuma prescrição de remédios');
      } else {
        speak('Remédio um, ${document["pill1"]}. horário ${document["time1"]}.'
            'Remédio dois, ${document["pill2"]}. horário ${document["time2"]}.');
        String teste = document["time1"];
        List strs = teste.split(':');
        int hour = int.parse(strs[0]);
        int minute = int.parse(strs[1]);

        Duration timeStamp = hour.hours + minute.minutes;
        Duration timeStampNow = DateTime.now().hour.hours +
            DateTime.now().minute.minutes +
            DateTime.now().second.seconds +
            DateTime.now().millisecond.milliseconds;

        Duration interval = timeStamp - timeStampNow;
        Future.delayed(Duration(seconds: interval.inSeconds), () async {
          speak("Hora de tomar o remédio. Hora de tomar remédio.");
          final Firestore _firestore = Firestore.instance;
          await _firestore
              .collection('box')
              .document('boxA')
              .setData({'gate': true});
        });
        print(interval.inSeconds);
        print(timeStamp);
        print(timeStampNow);
      }
    }
    if (counter == 0 && text == 'remédios' && !medicalAppointmentIsDone) {
      speak('Você ainda não tem nenhuma prescrição de remédios');
    }
  }
}
