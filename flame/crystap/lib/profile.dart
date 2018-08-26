import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:play_games/play_games.dart';

import 'util.dart';

class Profile {
  Image userImage;
  Account user;

  Profile(this.user) {
    user.iconImage.then((image) => userImage = image);
  }

  void render(Canvas c, Offset o) {
    final p = Flame.util.text(user.email, fontFamily: 'Pixel', fontSize: 24.0, color: white);

    Rect bg = new Rect.fromLTWH(o.dx, o.dy, 38.0 + p.width, 32.0);
    c.drawRect(bg, new Paint()..color = const Color(0xFFFF00FF));

    p.paint(c, Offset(o.dx + 36.0, o.dy + (32.0 - p.height) / 2));

    if (userImage != null) {
      Rect bounds = new Rect.fromLTWH(0.0, 0.0, userImage.width.toDouble(), userImage.height.toDouble());
      Rect dst = new Rect.fromLTWH(o.dx, o.dy, 32.0, 32.0);
      c.drawImageRect(userImage, bounds, dst, pWhite);
    }
  }
}