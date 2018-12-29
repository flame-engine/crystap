import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:play_games/play_games.dart';

import 'crystal.dart';
import 'toast.dart';
import 'profile.dart';
import 'util.dart';

class MyGame extends BaseGame {
  Sprite bag = Sprite('bag.png');

  Profile profile;

  bool menu = false;
  bool loading = true;
  String error;

  Crystal crystal;

  Rect get _bagRect => Rect.fromLTWH(size.width - 16.0 - ICON_SIZE, 16.0, ICON_SIZE, ICON_SIZE);

  Rect get _syncRect => Rect.fromLTWH(32.0, size.height - 64.0 - 32.0, size.width - 64.0, 64.0);

  MyGame() {
    singIn();
  }

  @override
  void render(Canvas c) {
    c.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), pBlack);
    if (loading) {
      final p = text('LOADING...');
      p.paint(c, Offset((size.width - p.width) / 2, (size.height - p.height) / 2));
    } else if (profile == null) {
      final p = text(error, fontSize: 8.0);
      p.paint(c, Offset((size.width - p.width) / 2, (size.height - p.height) / 2));

      final p2 = text('TAP TO SIGN IN AGAIN');
      p2.paint(c, Offset((size.width - p2.width) / 2, (size.height - p2.height) / 2 + p.height + 16.0));
    } else {
      super.render(c);

      profile.render(c, Offset(16.0, 16.0));

      c.drawRect(_bagRect, pUiBg);
      bag.renderRect(c, _bagRect);

      c.drawRect(_syncRect, pUiBg);
      final p = text('Save Progress');
      p.paint(c, Offset((size.width - p.width) / 2, (_syncRect.top + (_syncRect.height - p.height) / 2)));
    }
  }

  void singIn() async {
    SigninResult result = await PlayGames.signIn(scopeSnapshot: true); // allow to load/save games later
    if (result.success) {
      await PlayGames.setPopupOptions();
      profile = Profile(result.account);

      int startAmount = await fetchStartAmount();
      add(crystal = new Crystal(startAmount));
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
      } else if (_syncRect.contains(p.toOffset())) {
        loading = true;
        saveAmount(crystal.amount).then((bool m) {
          loading = false;
          addLater(ToastComponent(m ? 'Saved successfully' : 'Error')..resize(size));
        });
      } else {
        crystal.up();
      }
    }
  }

  Future<int> fetchStartAmount() async {
    Snapshot save = await PlayGames.openSnapshot('crystap.main'); // load the existing save or create a new empty one if none exists
    if (save.content == null || save.content.trim().isEmpty) {
      return 0; // default value when there is no save
    }
    return int.parse(save.content);
  }

  Future<bool> saveAmount(int amount) async {
    bool result = await PlayGames.saveSnapshot('crystap.main', amount.toString()); // save the current state to the snapshot
    await PlayGames.openSnapshot('crystap.main'); // reopen snapshot after save
    return result;
  }
}
