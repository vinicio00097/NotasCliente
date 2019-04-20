import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notas_cliente/Utils/ConnectionStatusSingleton.dart';
import 'package:notas_cliente/Utils/LoginBloc.dart';
import 'package:notas_cliente/Utils/LoginProvider.dart';
import 'package:notas_cliente/View/Login/PasswordWidget.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:notas_cliente/View/Login/RetryWidget.dart';
import 'package:notas_cliente/View/Menu/MenuActivity.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  int _methodLogin=1;
  bool _oneTime=false;
  bool _internet=true;
  final _flutterWebviewPlugin=new FlutterWebviewPlugin();
  final _targetURL="https://apps.umg.edu.gt/";
  SharedPreferences appStorage;
  StreamSubscription _connectionChangeStream;
  bool _isOnline = false;

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
        _flutterWebviewPlugin.launch(
          _targetURL,
          withJavascript: true,
          hidden: true,
        );

        _flutterWebviewPlugin.onDestroy.listen((onDestroy){
          _flutterWebviewPlugin.dispose();
          exit(0);
        });

        _flutterWebviewPlugin.onHttpError.listen((onHttpError){

        });

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

                  _goHome();

                  _flutterWebviewPlugin.dispose();
                  _flutterWebviewPlugin.close();
                });
              }else{
                if(_oneTime){
                  _flutterWebviewPlugin.evalJavascript(
                      "javascript:(function() { " +
                          "document.getElementsByClassName('one-google')[0].outerHTML = '';" +
                          "document.getElementsByClassName('google-footer-bar')[0].outerHTML = '';" +
                          "document.getElementsByClassName('need-help')[0].outerHTML = '';" +
                          "document.getElementById('link-forgot-passwd').outerHTML = '';"
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
          /*String html=await rootBundle.loadString('assets/Acceso_ cuentas de Google.html');
          _flutterWebviewPlugin.launch(
            new Uri.dataFromString(html, mimeType: 'text/html',encoding: Encoding.getByName("UTF-8")).toString(),
            withJavascript: true
          );*/
          _internet=!_internet;

          setState(() {
          });
        }
      }
    });

  }

  void _goHome(){
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context)=>MenuState(
          title: "Menu",
          flutterWebviewPlugin: _flutterWebviewPlugin,
        ))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: /*_methodLogin==1?*/_internet?Center(
        child: Container(
          width: 60.0,
          height: 60.0,
          child: CircularProgressIndicator(
            strokeWidth: 5.0,
            //valueColor: AlwaysStoppedAnimation(Colors.black),
          ),
        ),
      ):Center(
        child: retryState(
          onRetryClick: (){
            _loginAction();
            _internet=!_internet;

            setState(() {
            });
          },
        ),
      )/*Center(
        child: Form(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    "Iniciar Sesión",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                TextFormField(
                  //controller: mountController,
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    letterSpacing: 1.0,
                    fontSize: 20.0,
                    color: Colors.black
                  ),
                  validator: (text){
                    if(text.isEmpty){
                      return "Campo obligatorio.";
                    }else{
                      if(RegExp("^(\\s)+\$").hasMatch(text)){
                        return "Campo obligatorio.";
                      }
                    }
                  },
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                PasswordState(),
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: AnimatedPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
                    duration: Duration(seconds: 5),
                    child: FlatButton(
                      shape: StadiumBorder(),
                      onPressed: (){

                      },
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        "Iniciar sesión",
                        style: TextStyle(
                            letterSpacing: 3.0,
                            fontSize: 20.0
                        ),
                      ),
                      color: Color.fromRGBO(133, 144, 255, 1),
                      colorBrightness: Brightness.dark,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                Text(
                  "o",
                  style: TextStyle(
                    color: Colors.black38
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                RaisedButton(
                  padding: EdgeInsets.all(15.0),
                  color: Colors.white,
                  elevation: 1.0,
                  highlightElevation: 2.0,
                  shape: CircleBorder(),
                  onPressed: (){
                    
                  },
                  child: Image.asset(
                    "assets/icon_google.png",
                    width: 20,
                    height: 20,
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
              ],
            ),
          )
        ),
      )*/,
    );
  }
}