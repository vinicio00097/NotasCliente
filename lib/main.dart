import 'package:flutter/material.dart';
import 'package:notas_cliente/Utils/LoginProvider.dart';
import 'package:notas_cliente/View/Login/LoginActivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Utils/ThemeSingleton.dart';

//void main() => runApp(MyApp());
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();


  SharedPreferences appData=await SharedPreferences.getInstance();
  if(appData.getBool("themeManagerActive")==null) appData.setBool("themeManagerActive", false);
  if(appData.getBool("isDark")==null) appData.setBool("isDark", false);
  themeSingleton.isDark=appData.getBool("isDark");
  themeSingleton.isThemeManagerActive=appData.getBool("themeManagerActive");

  runApp(MyApp(isDark: themeSingleton.isDark,));
}

class MyApp extends StatelessWidget {
  final isDark;

  const MyApp({Key key, this.isDark}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas UMG',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        //primarySwatch: Colors.black,
        accentColor: Colors.black26,
        /*textTheme: TextTheme(
          title: TextStyle(

          )
        )*/
      ),
      /*darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.black26,
      ),*/
      home: SafeArea(
          child: LoginState(title: "Iniciar Sesión",)
      )/*,*/
    );
  }
}