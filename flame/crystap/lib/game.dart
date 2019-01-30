import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:play_games/play_games.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

import 'crystal.dart';
import 'toast.dart';
import 'profile.dart';
import 'util.dart';

class MyGame extends BaseGame {
  Sprite bag = Sprite('bag.png');
  Sprite coins = Sprite('coins.png');
  Sprite check = Sprite('check.png');

  Profile profile;
  bool pro = false;
  IAPItem iap;

  bool menu = false;
  bool loading = true;
  String error;

  Crystal crystal;

  Rect get _bagRect => Rect.fromLTWH(size.width - 2 * (16.0 + ICON_SIZE), 16.0, ICON_SIZE, ICON_SIZE);

  Rect get _coinRect => Rect.fromLTWH(size.width - (16.0 + ICON_SIZE), 16.0, ICON_SIZE, ICON_SIZE);

  Rect get _checkCoinRect => Rect.fromLTWH(size.width - (16.0 + ICON_SIZE / 2), 16.0 + ICON_SIZE / 2, ICON_SIZE / 2, ICON_SIZE / 2);

  Rect get _syncRect => Rect.fromLTWH(32.0, size.height - 64.0 - 32.0, (size.width - 64.0 - 32.0) / 2, 64.0);

  Rect get _leaderboardRect => Rect.fromLTWH((size.width - 64.0 - 32.0) / 2 + 64.0, size.height - 64.0 - 32.0, (size.width - 64.0 - 32.0) / 2, 64.0);

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

      int alpha = pro ? 50 : 255;
      c.drawRect(_coinRect, new Paint()..color = uiBg.withAlpha(alpha));
      if (coins.loaded()) {
        c.drawImageRect(coins.image, coins.src, _coinRect, new Paint()..color = const Color(0xFFFFFFFF).withAlpha(alpha));
      }
      if (pro) {
        check.renderRect(c, _checkCoinRect);
      }

      c.drawRect(_syncRect, pUiBg);
      final p = text('Save Progress', fontSize: 24.0);
      p.paint(c, Offset(_syncRect.left + (_syncRect.width - p.width) / 2, _syncRect.top + (_syncRect.height - p.height) / 2));

      c.drawRect(_leaderboardRect, pUiBg);
      final p2 = text('Leaderboard', fontSize: 24.0);
      p2.paint(c, Offset(_leaderboardRect.left + (_leaderboardRect.width - p2.width) / 2, _leaderboardRect.top + (_leaderboardRect.height - p2.height) / 2));
    }
  }

  void singIn() async {
    SigninResult result = await PlayGames.signIn(scopeSnapshot: true); // allow to load/save games later
    if (result.success) {
      await PlayGames.setPopupOptions();
      profile = Profile(result.account);

      int startAmount = await fetchStartAmount();
      add(crystal = new Crystal(startAmount));
      await setupInAppPurchase();
    } else {
      error = result.message;
    }
    loading = false;
  }

  Future setupInAppPurchase() async {
    await FlutterInappPurchase.initConnection;
    List<IAPItem> items = await FlutterInappPurchase.getProducts(['crystap_pro']);
    List<PurchasedItem> purchases = await FlutterInappPurchase.getPurchaseHistory();
    iap = items.first;
    if (purchases.isNotEmpty && purchases.first.productId == iap.productId) {
      pro = true;
    }
  }

  Future<void> purchase() async {
    try {
      PurchasedItem purchased = await FlutterInappPurchase.buyProduct(iap.productId);
      print('Purchace: $purchased');
      addLater(ToastComponent('Succesfully purchased the game!')..resize(size));
      pro = true;
      // one time add 100.000 crystals & save
      crystal.tap(100000);
      await saveAmount(crystal.amount);
      PlayGames.unlockAchievementByName('achievement_be_pro');
    } catch (e) {
      print('Error $e');
      addLater(ToastComponent('Unexpected error on buying the product.')..resize(size));
    }
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
      } else if (_coinRect.contains(p.toOffset())) {
        if (!pro) {
          loading = true;
          purchase().then((_) => loading = false);
        }
      } else if (_syncRect.contains(p.toOffset())) {
        loading = true;
        saveAmount(crystal.amount).then((bool m) {
          loading = false;
          addLater(ToastComponent(m ? 'Saved successfully' : 'Error')..resize(size));
        });
      } else if (_leaderboardRect.contains(p.toOffset())) {
        ScoreResults results = await PlayGames.loadPlayerCenteredScoresByName('leaderboard_high_scores', TimeSpan.TIME_SPAN_ALL_TIME, CollectionType.COLLECTION_PUBLIC, 10, forceReload: true);
        print('------');
        print(results.leaderboardDisplayName);
        print(results.scores.length);
        print(results.scores.first.rank);
        print(results.scores.first.rawScore);
        print('------');
      } else {
        crystal.tap(pro ? 2 : 1);
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
    SubmitScoreResults submitResult = await PlayGames.submitScoreByName('leaderboard_high_scores', amount);
    print('----');
    print(submitResult);
    print(submitResult.scoreResultAllTime.formattedScore);
    print('----');
    return result;
  }
}
