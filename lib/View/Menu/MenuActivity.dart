import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notas_cliente/Model/MenuItem.dart';
import 'package:notas_cliente/Model/WebServiceItem.dart';
import 'package:notas_cliente/Utils/LoginProvider.dart';
import 'package:notas_cliente/Utils/ThemeSingleton.dart';
import 'package:notas_cliente/View/Horario/HorarioActivity.dart';
import 'package:notas_cliente/View/Login/LoginActivity.dart';
import 'package:notas_cliente/View/Menu/ThemeListWidget.dart';
import 'package:notas_cliente/View/Notas/NotasActivity.dart';
import 'package:notas_cliente/View/Pensum/PensumActivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'ThemeListDialog.dart';

class MenuState extends StatefulWidget{
  MenuState({
    Key key,
    this.title,
    this.flutterWebviewPlugin,
    this.webServicesSource
  });
  
  final title;
  String webServicesSource;
  final FlutterWebviewPlugin flutterWebviewPlugin;
  @override
  State<StatefulWidget> createState() {
    return MenuWidget();
  }
}

class MenuWidget extends State<MenuState>{
  List<MenuItem> _menuItems=[
    new MenuItem(itemTitle: "Notas",color: /*Color.fromRGBO(53, 56, 84, 1)*/Colors.blue,icon: Icons.grade),
    new MenuItem(itemTitle: "Pensum",color: Colors.amber,icon: Icons.format_list_bulleted),
    new MenuItem(itemTitle: "Horario",color: Colors.purple[400],icon: Icons.date_range),
    new MenuItem(itemTitle: "Cerrar sesión",color: Colors.deepOrangeAccent,assetImage: "assets/log-out.png")
  ];

  AppBar appBar;
  SharedPreferences _appStorage;
  List<WebServiceItem> urls=[];
  var localAuth = new LocalAuthentication();
  Map<String,String> _cookies=new Map();
  int _countDarkMode=0;
  bool isManually=false;

  void initState() {
    _initAppStorage().then((onValue){

    });

    _dynamicURLs();
    super.initState();
  }
  
  void _dynamicURLs()async{
    urls.clear();
    if(widget.webServicesSource!=null){
      dom.Document document=parse(jsonDecode(widget.webServicesSource));
      List<String> labels=["notas","horarios","pensum"];
      List<dom.Element> list=document.getElementsByTagName("li");

      for(String label in labels){
        int index=list.indexWhere((item)=>item.getElementsByTagName("h3")[0].text.toLowerCase().contains(label));

        if(index>0){
          urls.add(new WebServiceItem(
              titulo: list.elementAt(index).getElementsByTagName("h3")[0].text.trim(),
              url: list.elementAt(index).getElementsByTagName("a")[0].attributes["href"]
          ));
        }else{
          urls.add(new WebServiceItem(titulo: "",url: ""));
        }
      }
    }
  }

  Future<dynamic> _initAppStorage() async {
    _appStorage=await SharedPreferences.getInstance();
    for(String key in _appStorage.getKeys()){
      if(key!="isDark"&&key!="themeManagerActive") _cookies[key]=_appStorage.get(key);
    }

    _appStorage.setBool("isDark", true);
    return true;
  }

  AppBar _getAppBar(){
    appBar=AppBar(
      elevation: 0.0,
      centerTitle: true,
      title: Text(
        widget.title,
        style: TextStyle(
            color: themeSingleton.isDark?Colors.white:Colors.black,
            fontSize: 25.0
        ),
      ),
      backgroundColor: themeSingleton.isDark?Colors.black:Colors.white,
      automaticallyImplyLeading: false,
    );
    return appBar;
  }

  void _getSelectedOption(int index,String title){
    int indexURL=urls.indexWhere((item)=>item.titulo.toLowerCase().contains(title.toLowerCase()));

    print(urls.indexWhere((item)=>item.titulo.toLowerCase().contains(title.toLowerCase())));
    switch(index){
      case 0:{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=>NotasState(
            title: title,
            url: indexURL<0?null:urls.elementAt(indexURL).url,
          ))
        );
        //_selectOptionGrades();
      }break;
      case 1:{
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>PensumState(
              title: title,
              url: indexURL<0?null:urls.elementAt(indexURL).url,
            ))
        );
      }break;
      case 2:{
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>HorarioState(
              title: title,
              url: indexURL<0?null:urls.elementAt(indexURL).url,
            ))
        );
      }break;
      case 3:{
        _closeSession();
      }break;
    }
  }

  void _closeSession()async{
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            titleTextStyle: TextStyle(
              color: Colors.white
            ),
            contentTextStyle: TextStyle(
              color: Colors.white
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15.0)
              )
            ),
            backgroundColor: themeSingleton.isDark?Color.fromRGBO(68, 68, 68, 1):Colors.deepOrangeAccent,
            title: Text("Confirmación"),
            content: Text("Esta seguro de cerrar sesión ?"),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.white,
                  onPressed: (){
                    Navigator.pop(context,false);
                  },
                  child: Text("No")
              ),
              FlatButton(
                  textColor: Colors.white,
                  onPressed: (){
                    Navigator.pop(context,true);
                  },
                  child: Text("Si")
              ),
            ],
          );
        }
    ).then((onValue){
      if(onValue!=null){
        if(onValue){
          widget.flutterWebviewPlugin.cleanCookies();
          //_appStorage.clear();
          for(String key in _appStorage.getKeys()){
            if(key!="isDark"&&key!="themeManagerActive"){
              _appStorage.remove(key);
            }
          }


          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context)=>LoginState(
                  title: "Login",
                )
            )
          );
        }
      }
    });
  }

  void _onLongPressCloseSession(context){
    if(!_appStorage.getBool("themeManagerActive")){
      _countDarkMode++;
      if(_countDarkMode>=2){
        int left=5-_countDarkMode;
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Estas a $left pasos de activar el administrador de temas."
                )
            )
        );

        if(left==1){
          _appStorage.setBool("themeManagerActive", true);
          themeSingleton.isThemeManagerActive=_appStorage.get("themeManagerActive");

          _countDarkMode=0;
        }
      }
    }else{
      Scaffold.of(context).hideCurrentSnackBar();
      _showThemeManagerDialog();
    }
  }

  void _showThemeManagerDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return ThemeDialog(
            title: "hola",
            onChangeTheme: (theme){
              if(theme.themeName=="Oscuro"){
                themeSingleton.isDark=true;
                _appStorage.setBool("isDark", themeSingleton.isDark);
              }else{
                themeSingleton.isDark=false;
                _appStorage.setBool("isDark", themeSingleton.isDark);
              }
              isManually=true;
              setState(() {
              });
            },
          );
        }
    ).then((onValue){
      if(onValue!=null){
        if(onValue){
          setState(() {
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height=((MediaQuery.of(context).size.height)/_menuItems.length)-20;
    var brightness = MediaQuery.of(context).platformBrightness;

    if(!themeSingleton.isThemeManagerActive){
      themeSingleton.isDark=brightness == Brightness.dark;
    }

    if(_appStorage!=null) _appStorage.setBool("isDark", themeSingleton.isDark);

    return Theme(
      data: ThemeData(
          brightness: themeSingleton.isDark?Brightness.dark:Brightness.light,
          accentColor: Colors.black26,
      ),
      child: Scaffold(
        appBar: _getAppBar(),
        body: ListView.builder(
          itemBuilder: (context,index){
            return Stack(
              children: <Widget>[
                SizedBox.fromSize(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(0.0)
                        )
                    ),
                    margin: EdgeInsets.zero,
                    color: themeSingleton.isDark?Colors.black:_menuItems[index].color,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        index==_menuItems.length-1?Image.asset(
                          _menuItems[index].assetImage,
                          width: 70.0,
                          height: 70.0,
                          color: themeSingleton.isDark?_menuItems[index].color:Colors.white,
                        ):Icon(
                          _menuItems[index].icon,
                          size: 70.0,
                          color: themeSingleton.isDark?_menuItems[index].color:Colors.white,
                        ),
                        Text(
                          _menuItems[index].itemTitle,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        )
                      ],
                    ),
                  ),
                  size: Size.fromHeight(height),
                ),
                new Positioned.fill(
                    child: new Material(
                      color: Colors.transparent,
                      child: new InkWell(
                        onTap: (){
                          _getSelectedOption(index,_menuItems[index].itemTitle);
                        },
                        onLongPress: index==_menuItems.length-1?(){
                          if(index==_menuItems.length-1) _onLongPressCloseSession(context);
                        }:null,
                      ),
                    )
                )
              ],
            );
          },
          itemCount: _menuItems.length,
        ),
      ),
    );
  }
  
}