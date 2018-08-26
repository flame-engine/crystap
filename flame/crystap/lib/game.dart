import 'dart:async';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import 'package:play_games/play_games.dart';

import 'util.dart';
import 'profile.dart';

class MyGame extends BaseGame {

  Sprite bag = new Sprite('bag.png');

  Profile profile;

  bool menu = false;
  bool loading = true;
  String error;

  int crystals = 0; // TODO firebase!

  Rect get _bagRect => new Rect.fromLTWH(size.width - 16.0 - 32.0, 16.0, 32.0, 32.0);

  MyGame() {
    singin();
  }

  @override
  void render(Canvas c) {
    c.drawRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height), pBlack);
    if (loading) {
      final p = Flame.util.text('LOADING...', fontFamily: 'Pixel', fontSize: 36.0, color: white);
      p.paint(c, Offset((size.width - p.width)/2, (size.height - p.height)/2));
    } else if (profile == null) {
      final p = Flame.util.text(error, fontFamily: 'Pixel', fontSize: 8.0, color: white);
      p.paint(c, Offset((size.width - p.width)/2, (size.height - p.height)/2));

      final p2 = Flame.util.text('TAP TO SIGN IN AGAIN', fontFamily: 'Pixel', fontSize: 36.0, color: white);
      p2.paint(c, Offset((size.width - p2.width)/2, (size.height - p2.height)/2 + p.height + 16.0));
    } else {
      super.render(c);

      final p = Flame.util.text(crystals.toString(), fontFamily: 'Pixel', fontSize: 48.0, color: white);
      p.paint(c, Offset((size.width - p.width)/2, (size.height - p.height)/2));

      profile.render(c, Offset(16.0, 16.0));
      bag.renderRect(c, _bagRect);
    }
  }

  void singin() async {
    try {
      SigninResult result = await PlayGames.signIn();
      if (result.success) {
        await PlayGames.setPopupOptions();
        profile = new Profile(result.account);
      } else {
        error = result.message;
      }
      loading = false;
    } catch (ex) {
      error = ex.toString();
    }
  }

  void tapDown(Position p) async {
    if (loading || menu || error != null) {
      return;
    }
    if (profile == null) {
      singin();
    } else {
      if (_bagRect.contains(p.toOffset())) {
        menu = true;
        PlayGames.showAchievements().then((_) => menu = false);
      } else {
        menu = true;
        bool a1 = await PlayGames.unlockAchievementByName('achievement_tap_once');
        bool a2 = await PlayGames.incrementAchievementByName('achievement_tap_10_times');
        bool a3 = await PlayGames.incrementAchievementByName('achievement_tap_100_times');
        print([a1, a2, a3]);
        crystals++;
        menu = false;
      }
    }
  }
}
