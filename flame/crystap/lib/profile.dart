import 'dart:ui';

import 'package:play_games/play_games.dart';

import 'util.dart';

class Profile {

  Image userImage;
  Account user;

  Profile(this.user) {
    user.iconImage.then((image) => userImage = image);
  }

  void render(Canvas c, Offset o) {
    final p = text(user.displayName, fontSize: 24.0);

    Rect bg = new Rect.fromLTWH(o.dx, o.dy, ICON_SIZE + 2 * MARGIN + p.width, ICON_SIZE);
    c.drawRect(bg, pUiBg);

    p.paint(c, Offset(o.dx + ICON_SIZE + MARGIN, o.dy + (ICON_SIZE - p.height) / 2));

    if (userImage != null) {
      Rect bounds = new Rect.fromLTWH(0.0, 0.0, userImage.width.toDouble(), userImage.height.toDouble());
      Rect dst = new Rect.fromLTWH(o.dx, o.dy, ICON_SIZE, ICON_SIZE);
      c.drawImageRect(userImage, bounds, dst, pWhite);
    }
  }
}