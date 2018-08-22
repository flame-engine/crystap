import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';

import 'util.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyGame extends BaseGame {

  FirebaseAuth _auth;
  GoogleSignIn _googleSignIn;

  FirebaseUser user;
  bool loading = true;
  String error;

  MyGame() {
    _googleSignIn = new GoogleSignIn.games();
    _auth = FirebaseAuth.instance;
    // signInSilently();
    loading = false;
  }

  signInSilently() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signInSilently();
    if (googleUser != null) {
      await handleSignIn(googleUser);
    }
    print('ltrue');
    loading = false;
    print('lfalse');
  }

  handleSignIn(GoogleSignInAccount googleUser) async {
    print('h1');
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print('h2');
    user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print('h3');
    print(user);
    print('h4');
  }

  @override
  void render(Canvas c) {
    c.drawRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height), pBlack);
    if (error != null) {
      final p = Flame.util.text(error, fontFamily: 'Pixel', fontSize: 8.0, color: white);
      p.paint(c, Offset((size.width - p.width)/2, (size.height - p.height)/2));
    } else if (loading) {
      final p = Flame.util.text('LOADING...', fontFamily: 'Pixel', fontSize: 36.0, color: white);
      p.paint(c, Offset((size.width - p.width)/2, (size.height - p.height)/2));
    } else if (user == null) {
      final p = Flame.util.text('TAP TO SIGN IN', fontFamily: 'Pixel', fontSize: 36.0, color: white);
      p.paint(c, Offset((size.width - p.width)/2, (size.height - p.height)/2));
    } else {
      print('user not null');
      super.render(c);
      final p = Flame.util.text(user.email, fontFamily: 'Pixel', fontSize: 24.0, color: white);
      p.paint(c, Offset(size.width - p.width - 16.0, size.height - p.height - 16.0));
    }
  }

  void tapDown(Position p) async {
    if (loading || error != null) {
      return;
    }
    if (user == null) {
      try {
        print('s1');
        loading = true;
        print('s2');
        GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        print('s3');
        await handleSignIn(googleUser);
        print('s4');
        loading = false;
      } catch (ex) {
        error = ex.toString();
      }
    } else {
      // TODO tap crystal
    }
  }
}
