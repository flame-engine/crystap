import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'game.dart';

MyGame game = new MyGame();

main() async {
  Flame.audio.disableLog();
  Flame.util.fullScreen();

  runApp(new MaterialApp(
    routes: {
      '/': (BuildContext ctx) => game.widget,
    },
  ));

  Flame.util.addGestureRecognizer(new MultiTapGestureRecognizer()
    ..onTapDown = (int pointer, TapDownDetails details) {
      Position p = new Position.fromOffset(details.globalPosition);
      game?.tapDown(p);
    }
  );
}