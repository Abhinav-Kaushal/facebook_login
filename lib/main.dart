import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http ;

import 'dart:convert' as JSON ;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLogin = false;
  Map userProfile;

  final facebook_login = FacebookLogin();

  _loginFB() async {
    final result = await facebook_login.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = JSON.jsonDecode(graphResponse.body);
        print(profile);
        setState(() {
          userProfile = profile;
          _isLogin = true;
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => _isLogin = false );
        break;
      case FacebookLoginStatus.error:
        setState(() => _isLogin = false );
        break;
    }
  }
  _logout(){
    facebook_login.logOut();
    setState(() {
      _isLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child:  _isLogin ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(userProfile["picture"]["data"]["url"], height: 100.0 , width: 100.0,),
              SizedBox(height: 5,),
              Text(userProfile["name"]),
              RaisedButton( color: Colors.blue,
                textColor: Colors.white,
                child:Text("Logout"),
                onPressed: (){
                _logout();
                },)

            ], )  : RaisedButton(
            color: Colors.blue,
            textColor: Colors.white,
            child:Text("Login With facebook"),
            onPressed: (){
              _loginFB();
            },
          ),
        ),
      ),
    );
  }
}
