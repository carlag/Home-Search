import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proper_house_search/data/services/login_service.dart';

import '../../data/services/property_service.dart';
import '../home.dart';

enum UserState {
  error,
  authenticated,
  unknown,
}

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
  final service = LoginService();
  var _state = UserState.unknown;
  var _accessToken;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount account) async {
      final authentication = await account.authentication;
      _accessToken = await service.swapTokens(authentication.idToken);
      setState(() {
        if (_accessToken != null) {
          _currentUser = account;
          _state = UserState.authenticated;
        } else {
          _currentUser = null;
          _state = UserState.error;
        }
      });
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
    if (_currentUser != null && _state == UserState.authenticated) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: MyHomePage(
              title: 'Proper-ty Search',
              key: Key('homepage'),
              propertyService: PropertyService(_accessToken),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          if (_state == UserState.error) Text('Error authenticated user'),
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
