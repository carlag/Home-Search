import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../home.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>['email'],
);

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  String? _contactText;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {}
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: MyHomePage(
              title: 'Proper-ty Search',
              key: Key('homepage'),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Search'),
        actions: <Widget>[
          FlatButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }
}
