import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

class UserData extends ChangeNotifier {
  var userData = {};
  var medicalRecord = {};

  void addUserInfo(Map map) {
    userData = Map.of(map);
    print(userData);
  }

  void updateMedicalRecord(Map map) {
    medicalRecord = Map.of(map);
    print(medicalRecord);
  }
}
