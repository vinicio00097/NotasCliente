import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:notas_cliente/Utils/LoginBloc.dart';

class LoginProvider extends InheritedWidget {
  //final LoginBloc bloc;
  final FlutterWebviewPlugin _flutterWebviewPlugin;

  LoginProvider({Key key, Widget child})
      : _flutterWebviewPlugin= new FlutterWebviewPlugin(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static FlutterWebviewPlugin of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(LoginProvider) as LoginProvider)._flutterWebviewPlugin;
  }
}