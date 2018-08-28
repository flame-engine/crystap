import 'dart:ui' as ui show Color, Paint;
import 'package:flutter/material.dart' as material show TextPainter;

import 'package:flame/flame.dart';

const double ICON_SIZE = 64.0;
const double MARGIN = 4.0;

const ui.Color black = const ui.Color(0xFF000000);
const ui.Color white = const ui.Color(0xFFFFFFFF);
const ui.Color uiBg = const ui.Color(0xFFFF00FF);


final ui.Paint pBlack = new ui.Paint()..color = black;
final ui.Paint pWhite = new ui.Paint()..color = white;
final ui.Paint pUiBg = new ui.Paint()..color = uiBg;

material.TextPainter text(String txt, { double fontSize = 36.0, ui.Color color = white }) => Flame.util.text(txt, fontFamily: 'Stacked', fontSize: fontSize, color: color);