import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class BasicMic extends StatelessWidget {
  final bool isListening;
  final Function listen;
  final Function help;
  BasicMic({this.isListening, this.listen, this.help});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarGlow(
            animate: isListening,
            glowColor: Colors.red,
            endRadius: 200.0,
            duration: Duration(milliseconds: 2000),
            repeat: true,
            showTwoGlows: true,
            repeatPauseDuration: Duration(milliseconds: 100),
            child: MaterialButton(
              onLongPress: help,
              height: 200,
              minWidth: 200,
              elevation: 20,
              color: Colors.redAccent,
              shape: CircleBorder(),
              onPressed: listen,
              child: Icon(
                Icons.mic,
                color: Colors.white,
                size: 100,
              ),
            ),
          )
        ],
      ),
    );
  }
}
