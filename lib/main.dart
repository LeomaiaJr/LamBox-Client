import 'package:flutter/material.dart';
import 'package:lambox/models/user_data.dart';
import 'package:lambox/page/lambox_screen.dart';
import 'package:lambox/page/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MaterialApp(
        title: 'LamBox',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LamBoxScreen(),
      ),
    );
  }
}
