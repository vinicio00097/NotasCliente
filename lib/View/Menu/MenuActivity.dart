import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:notas_cliente/Model/MenuItem.dart';
import 'package:notas_cliente/Model/WebServiceItem.dart';
import 'package:notas_cliente/Utils/LoginProvider.dart';
import 'package:notas_cliente/View/Horario/HorarioActivity.dart';
import 'package:notas_cliente/View/Login/LoginActivity.dart';
import 'package:notas_cliente/View/Notas/NotasActivity.dart';
import 'package:notas_cliente/View/Pensum/PensumActivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    new MenuItem(itemTitle: "Notas",color: Color.fromRGBO(53, 56, 84, 1),icon: Icons.grade),
    new MenuItem(itemTitle: "Pensum",color: Colors.amber,icon: Icons.format_list_bulleted),
    new MenuItem(itemTitle: "Horario",color: Colors.purple[400],icon: Icons.date_range),
    new MenuItem(itemTitle: "Cerrar sesión",color: Colors.deepOrangeAccent,assetImage: "assets/log-out.png")
  ];

  AppBar appBar;
  SharedPreferences appStorage;
  List<WebServiceItem> urls=[];

  void initState() {
    _initAppStorage().then((onValue){

    });

    _dynamicURLs();
    super.initState();
  }
  
  void _dynamicURLs(){
    urls.clear();
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

  Future<dynamic> _initAppStorage() async {
    appStorage=await SharedPreferences.getInstance();
    return true;
  }

  AppBar _getAppBar(){
    appBar=AppBar(
      elevation: 0.0,
      centerTitle: true,
      title: Text(
        widget.title,
        style: TextStyle(
            color: Colors.black,
            fontSize: 25.0
        ),
      ),
      backgroundColor: Colors.white,
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

  void _closeSession(){
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
            backgroundColor: Colors.deepOrangeAccent,
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
          appStorage.clear();

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

  /*void _selectOptionGrades(){
    String semestre=DateTime.now().month<7?1.toString():2.toString();

    showModalBottomSheet(
        context: context,
        builder: (context){
          return(
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: double.infinity,
                      child: FlatButton(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Colors.black
                          )
                        ),
                        onPressed: (){
                          Navigator.pop(context,1);
                        },
                        child: Text("Ver actuales (Sementre "+semestre+" Año "+DateTime.now().year.toString()+")")
                      ),
                    ),
                    ButtonTheme(
                      minWidth: double.infinity,
                      child: FlatButton(
                        shape: StadiumBorder(
                            side: BorderSide(
                                color: Colors.black
                            )
                        ),
                        onPressed: (){
                          Navigator.pop(context,2);
                        },
                        child: Text("Selección (Semestre y Año)")
                      ),
                    ),
                  ],
                ),
              )
          );
        }
    ).then((onValue){

    });
  }*/

  @override
  Widget build(BuildContext context) {
    double height=((MediaQuery.of(context).size.height)/_menuItems.length)-20;
    
    return Scaffold(
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
                  color: _menuItems[index].color,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      index==_menuItems.length-1?Image.asset(
                        _menuItems[index].assetImage,
                        width: 70.0,
                        height: 70.0,
                        color: Colors.white,
                      ):Icon(
                        _menuItems[index].icon,
                        size: 70.0,
                        color: Colors.white,
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
                  )
                )
              )
            ],
          );
        },
        itemCount: _menuItems.length,
      ),
    );
  }
  
}