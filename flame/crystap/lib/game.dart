import 'dart:ui';

import 'package:crystap/crystal.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import 'package:play_games/play_games.dart';

import 'util.dart';
import 'profile.dart';

class MyGame extends BaseGame {

  Sprite bag = Sprite('bag.png');

  Profile profile;

  bool menu = false;
  bool loading = true;
  String error;

  Crystal crystal;

  Rect get _bagRect => Rect.fromLTWH(size.width - 16.0 - ICON_SIZE, 16.0, ICON_SIZE, ICON_SIZE);

  MyGame() {
    add(crystal = new Crystal());
    singIn();
  }

  @override
  void render(Canvas c) {
    c.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), pBlack);
    if (loading) {
      final p = text('LOADING...');
      p.paint(c, Offset((size.width - p.width)/2, (size.height - p.height)/2));
    } else if (profile == null) {
      final p = text(error, fontSize: 8.0);
      p.paint(c, Offset((size.width - p.width)/2, (size.height - p.height)/2));

      final p2 = text('TAP TO SIGN IN AGAIN');
      p2.paint(c, Offset((size.width - p2.width)/2, (size.height - p2.height)/2 + p.height + 16.0));
    } else {
      super.render(c);

      profile.render(c, Offset(16.0, 16.0));

      c.drawRect(_bagRect, pUiBg);
      bag.renderRect(c, _bagRect);
    }
  }

  void singIn() async {
    SigninResult result = await PlayGames.signIn();
    if (result.success) {
      await PlayGames.setPopupOptions();
      profile = Profile(result.account);
    } else {
      error = result.message;
    }
    loading = false;
  }

  void tapDown(Position p) async {
    if (loading || menu || error != null) {
      return;
    }
    if (profile == null) {
      singIn();
    } else {
      if (_bagRect.contains(p.toOffset())) {
        menu = true;
        PlayGames.showAchievements().then((_) => menu = false);
      } else {
        crystal.up();
      }
    }
  }
}
