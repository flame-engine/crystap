import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/flame.dart';

enum ToastDirection {
  TOP, BOTTOM
}

class ToastComponent extends Component with Resizable {

  static const MARGIN_Y = 128.0;
  static const WIDTH_FRAC = 0.75;
  static const HEIGHT = 32.0;

  static const FADE_SPEED = 1.2;
  static const CLOCK_WAIT = 1.5;

  final ToastDirection direction;
  final String text;
  final Color color;

  double speed = FADE_SPEED;
  double fade = 0;
  double clock;

  ToastComponent(this.text, { this.direction = ToastDirection.BOTTOM, this.color = const Color(0xFFFF00FF) });

  double get width => size.width * WIDTH_FRAC;
  double get top => direction == ToastDirection.TOP ? MARGIN_Y : size.height - HEIGHT - MARGIN_Y;
  Rect get position => Rect.fromLTWH((size.width - width) / 2, top, width, HEIGHT);

  @override
  void render(Canvas c) {
    int currentAlpha = (fade * 255).round();
    c.drawRRect(RRect.fromRectAndRadius(position, Radius.circular(8.0)), new Paint()..color = color.withAlpha(currentAlpha));
    final painter = Flame.util.text(text, color: const Color(0xFFFFFFFF).withAlpha(currentAlpha));
    painter.paint(c, new Offset(position.left + (position.width - painter.width) / 2, position.top + (position.height - painter.height) / 2));
  }

  @override
  void update(double t) {
    if (clock != null) {
      clock += t;
      if (clock > CLOCK_WAIT) {
        clock = null;
        speed *= -1;
      }
    } else {
      fade += speed * t;
      if (fade >= 1) {
        fade = 1;
        clock = 0;
      }
    }
  }

  @override
  bool destroy() => fade < 0;

  @override
  int priority() => 100;

}