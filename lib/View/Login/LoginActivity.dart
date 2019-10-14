import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notas_cliente/Utils/ConnectionStatusSingleton.dart';
import 'package:notas_cliente/Utils/LoginBloc.dart';
import 'package:notas_cliente/Utils/LoginProvider.dart';
import 'package:notas_cliente/Utils/ThemeSingleton.dart';
import 'package:notas_cliente/View/Login/PasswordWidget.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:notas_cliente/View/Login/RetryWidget.dart';
import 'package:notas_cliente/View/Menu/MenuActivity.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class LoginState extends StatefulWidget{
  LoginState({
    Key key,
    this.title
  }):super(key:key);

  final title;

  @override
  State<StatefulWidget> createState() {
    return LoginWidget();
  }
}

class LoginWidget extends State<LoginState>{
  bool _oneTime=false,_internet=true;
  final _flutterWebviewPlugin=new FlutterWebviewPlugin();
  final _targetURL="https://apps.umg.edu.gt/";
  SharedPreferences appStorage;
  StreamSubscription _connectionChangeStream;
  bool _isOnline = false;
  var localAuth = new LocalAuthentication();
  String webServicesSource;
  static const platform = const MethodChannel('flutter_cliente_notas/request_basic_auth');

  Future<dynamic> _initAppStorage() async {
    appStorage=await SharedPreferences.getInstance();
    return true;
  }

  @override
  void initState() {
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);

    _initAppStorage().then((onValue){
      _loginAction();
    });

    super.initState();
  }

  void connectionChanged(dynamic hasConnection) {
    _isOnline = hasConnection;
    print(_isOnline);
  }

  Future _loginAction() async {
    await ConnectionStatusSingleton.verifyConnection().then((onValue) async {
      if(onValue){
        /*_flutterWebviewPlugin.launch(
          _targetURL,
          withJavascript: true,
          hidden: true,
        );*/

        _flutterWebviewPlugin.onStateChanged.listen((state) async{
          switch (state.type){
            case WebViewState.startLoad:{
              if(!_oneTime){
                _oneTime=!_oneTime;

                _flutterWebviewPlugin.hide();
              }
            }break;
            case WebViewState.finishLoad:{
              if(state.url==_targetURL){

                _flutterWebviewPlugin.getCookies().then((onCookies) async {
                  await onCookies.forEach((String Key,String Value){
                    appStorage.setString(Key,Value);
                    print("cookies");
                  });

                  _flutterWebviewPlugin.evalJavascript(
                    "document.getElementsByClassName('web-services')[0].innerHTML;"
                  ).then((onJavascript){
                    if(onJavascript!=null){
                      webServicesSource=onJavascript;
                    }

                    _accessWithBiometric().then((onValue){
                      _goHome();
                    });
                  });

                  _flutterWebviewPlugin.dispose();
                  _flutterWebviewPlugin.close();
                });
              }else{
                if(_oneTime){
                  String isDarkStyle=themeSingleton.isDark?"document.body.style.background = '#000000';" +
                      "document.getElementsByClassName('signin-card')[0].style.background='#222222';"+
                      "document.getElementsByClassName('wrapper')[0].style.background = '#000000';" +
                      "document.getElementsByClassName('card-mask')[0].style.background = '#000000';" +
                      "document.getElementById('profile-name').style.color = 'white';"+
                      "document.getElementById('email-display').style.color = 'white';"+
                      "document.getElementsByTagName('h2')[0].style.color= 'white';" +
                      "document.getElementsByClassName('one-google')[0].outerHTML = '';" +
                      "document.getElementsByClassName('google-footer-bar')[0].outerHTML = '';":"";
                  _flutterWebviewPlugin.evalJavascript(
                      "javascript:(function() { " +
                          "document.getElementsByClassName('one-google')[0].outerHTML = '';" +
                          "document.getElementsByClassName('google-footer-bar')[0].outerHTML = '';" +
                          "document.getElementsByClassName('need-help')[0].outerHTML = '';" +
                          "document.getElementById('link-forgot-passwd').outerHTML = '';"+
                          isDarkStyle+
                          "})();"
                  ).whenComplete((){
                    _oneTime=!_oneTime;

                    _flutterWebviewPlugin.show();
                  });
                }
              }
            }break;
            default:{
              print(state.type);
              print("no hay internet");
            }break;
          }
        });
      }else{
        if(appStorage.getKeys().length>0){
          _goHome();
        }else{
          _internet=!_internet;

          setState(() {
          });
        }
      }
    });

  }

  Future<dynamic> _accessWithBiometric()async{
    List<BiometricType> availableBiometrics=await localAuth.getAvailableBiometrics();

    print(availableBiometrics);

    if(availableBiometrics!=null){
      if(availableBiometrics.contains(BiometricType.fingerprint)){
        try {
          bool didAuthenticate = await localAuth.authenticateWithBiometrics(
            localizedReason: 'Por favor, identifíquese'
          );

          if(didAuthenticate){
            return 1;
          }else{
            return await _accessWithBiometric();
          }
        } on PlatformException catch (e) {
          print(e);
          return 2;
        }
      }else{
        int result=await _getBasicAuth();

        switch(result){
          case 1:{
            return result;
          }break;
          case 2:{
            return 1;
          }break;
          case 0:{
            return await _accessWithBiometric();
          }break;
        }
      }
    }else{
      return 4;
    }
  }

  Future<int> _getBasicAuth() async {
    try {
      final int result = await platform.invokeMethod('request_basic_auth');
      if(result==1){
        return 1;
      }else{
        if(result==0){
          return 0;
        }else{
          return 2;
        }
      }
    } on PlatformException catch (e) {
      return 0;
    }
  }

  void _goHome(){
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context)=>MenuState(
          title: "Menu",
          flutterWebviewPlugin: _flutterWebviewPlugin,
          webServicesSource: webServicesSource,
        ))
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;

    if(!themeSingleton.isThemeManagerActive){
      themeSingleton.isDark=brightness == Brightness.dark;
    }

    if(appStorage!=null) appStorage.setBool("isDark", themeSingleton.isDark);

    return Theme(
      data: ThemeData(
        brightness: themeSingleton.isDark?Brightness.dark:Brightness.light,
        accentColor: Colors.black26,
      ),
      child: Scaffold(
        backgroundColor: themeSingleton.isDark?Colors.black:null,
        body: _internet?WebviewScaffold(
          initialChild: Center(
            child: Container(
              width: 60.0,
              height: 60.0,
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation(Colors.deepOrangeAccent),
              ),
            ),
          ),
          appBar: AppBar(
            elevation: 0.0,
            title: Center(child: Text(
              'Iniciar sesión',
              style: TextStyle(
                fontSize: 25,
              ),
            )),
            backgroundColor: themeSingleton.isDark?Colors.black:Colors.deepOrangeAccent,
          ),
          url: _targetURL,
          withJavascript: true,
          hidden: true,
        ):Center(
          child: retryState(
            onRetryClick: (){
              _loginAction();
              _internet=!_internet;

              setState(() {
              });
            },
          ),
        ),
      ),
    );
  }
}