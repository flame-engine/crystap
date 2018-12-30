import 'dart:async';
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/position.dart';
import 'package:flame/audio_pool.dart';
import 'package:flame/sprite.dart';
import 'package:play_games/play_games.dart';

import 'util.dart';

class Crystal extends Component with Resizable {

  static Sprite sprite = Sprite('crystal.png');
  static Position _crystalSize = new Position(128.0, 128.0);

  static AudioPool sfx = new AudioPool('pickup.mp3', prefix: 'audio/', minPlayers: 5, maxPlayers: 5)..init();

  int amount;

  int _achieveCountCache = 0;

  Crystal(int startAmount) : amount = startAmount;

  void tap(int dx) {
    amount += dx;

    sfx.start(volume: 0.2);
    _achievements();
  }

  void _achievements() {
    if (_achieveCountCache == 0 && amount >= 1) {
      _runSingle(() => PlayGames.unlockAchievementByName('achievement_tap_once'));
      _achieveCountCache = 1;
    }
    if (_achieveCountCache == 1 && amount >= 10) {
      _runSingle(() => PlayGames.unlockAchievementByName('achievement_tap_10_times'));
      _achieveCountCache = 2;
    }
    if (_achieveCountCache == 2 && amount >= 100) {
      _runSingle(() => PlayGames.unlockAchievementByName('achievement_tap_100_times'));
      _achieveCountCache = 3;
    }
    if (_achieveCountCache == 3 && amount >= 1000) {
      _runSingle(() => PlayGames.incrementAchievementByName('achievement_tap_1000_times', 1000));
      _achieveCountCache = 4;
    }
    if (_achieveCountCache == 4 && amount >= 10000) {
      _runSingle(() => PlayGames.incrementAchievementByName('achievement_sir_tapalot', 10000));
      _achieveCountCache = 5;
    }
  }

  void _runSingle(Future<bool> Function() fn) async {
    bool didIt = false;
    while (!didIt) {
      didIt = await fn();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void render(Canvas c) {
    if (!sprite.loaded() || amount == null) {
      return;
    }

    sprite.renderCentered(c, new Position.fromSize(size).times(0.5), _crystalSize);

    final p = text(amount.toString(), fontSize: 48.0);
    p.paint(c, Offset((size.width - p.width)/2, (size.height + _crystalSize.y)/2 + MARGIN));
  }

  @override
  void update(double t) {}
}