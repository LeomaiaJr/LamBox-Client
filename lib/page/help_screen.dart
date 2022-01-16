import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:lambox/models/user_data.dart';
import 'package:lambox/utils/extensions.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  var userData;
  @override
  void initState() {
    super.initState();
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
    controller = AnimationController(
      duration: Duration(milliseconds: 500),
      upperBound: 2.00,
      vsync: this,
    );

    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse(from: 2);
      }
      if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                color: controller.value.toInt() == 0
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: FaIcon(
                        FontAwesomeIcons.briefcaseMedical,
                        color: controller.value.toInt() == 0
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        size: 40,
                      ),
                    ),
                    Text(
                      'SOCORRO',
                      style: TextStyle(
                          color: controller.value.toInt() == 0
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          fontSize: 55,
                          fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: FaIcon(
                        FontAwesomeIcons.briefcaseMedical,
                        color: controller.value.toInt() == 0
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: controller.value.toInt() == 0
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                child: Container(
                  padding: EdgeInsets.only(top: 15, left: 15),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Ficha Médica',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 40,
                            color: Colors.white),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: FaIcon(
                          FontAwesomeIcons.starOfLife,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    MedicalListTile(
                      typeIcon: Icons.person,
                      typeText: 'Nome',
                      contentText: userData['name'],
                    ),
                    MedicalListTile(
                      typeText: 'Sexo',
                      contentText: userData['gender'].toString().capitalize(),
                      typeIcon: FontAwesomeIcons.mars,
                    ),
                    MedicalListTile(
                      typeText: 'Data de Nascimento',
                      contentText: userData['birthday'],
                      typeIcon: Icons.perm_contact_calendar,
                    ),
                    MedicalListTile(
                      typeText: 'Altura e Peso',
                      contentText: userData['height'],
                      typeIcon: FontAwesomeIcons.child,
                    ),
                    MedicalListTile(
                      typeText: 'Tipo Sanguíneo',
                      contentText:
                          userData['bloodType'].toString().capitalize(),
                      typeIcon: FontAwesomeIcons.handHoldingHeart,
                    ),
                    MedicalListTile(
                      typeText: 'Alergias',
                      contentText: userData['alergies'],
                      typeIcon: FontAwesomeIcons.fileMedical,
                    ),
                    MedicalListTile(
                      typeText: 'Contato de Emergência',
                      contentText: userData['phoneNumber'],
                      typeIcon: Icons.phone_in_talk,
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicalListTile extends StatelessWidget {
  final String typeText;
  final String contentText;
  final IconData typeIcon;

  const MedicalListTile({this.typeText, this.contentText, this.typeIcon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(
              typeIcon,
              color: Colors.black,
              size: 30,
            ),
            Padding(
              padding: EdgeInsets.only(top: 6, left: 5),
              child: Text(
                typeText + ':',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            contentText,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
