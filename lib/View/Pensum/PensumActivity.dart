import 'package:flutter/material.dart';
import 'package:notas_cliente/Model/Curso.dart';
import 'package:notas_cliente/Model/PensumItem.dart';
import 'package:notas_cliente/Utils/ConnectionStatusSingleton.dart';
import 'package:notas_cliente/Utils/ThemeSingleton.dart';
import 'package:notas_cliente/View/Login/LoginActivity.dart';
import 'package:notas_cliente/ViewModel/PensumViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PensumState extends StatefulWidget{
  PensumState({
    Key key,
    this.title,
    this.url
  }):super(key:key);

  final title;
  String url;
  @override
  State<StatefulWidget> createState() {
    return PensumWidget();
  }
}

class PensumWidget extends State<PensumState>{
  bool _isLoading=true;
  List<PensumItem> _ciclosData=[];
  PensumViewModel _pensumViewModel=new PensumViewModel();
  Map<String,String> _cookies=new Map();
  final scaffoldKey=GlobalKey<ScaffoldState>();
  SharedPreferences _appStorage;


  @override
  void initState() {
    _initAppStorage().then((onValue){
      ConnectionStatusSingleton.verifyConnection().then((internetStatus){
        if(internetStatus){
          _getPensum().then((onPensumResponse){
            _isLoading=!_isLoading;

            setState(() {
            });
          });
        }else{
          scaffoldKey.currentState.removeCurrentSnackBar();
          scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text("No hay conexión a internet.")
            )
          );

          _isLoading=!_isLoading;

          setState(() {
          });
        }
      });
    });

    print(widget.url);
    super.initState();
  }

  Future<dynamic> _initAppStorage() async {
    _appStorage=await SharedPreferences.getInstance();

    for(String key in _appStorage.getKeys()){
      if(key!="isDark"&&key!="themeManagerActive") _cookies[key]=_appStorage.get(key);
    }

    return true;
  }

  Future<dynamic> _getPensum() async{
    await _pensumViewModel.getPensum(_cookies,widget.url).then((onPensumResponse){
      switch(onPensumResponse[0]){
        case 0:{
          _goLogin();
        }break;
        case 1:{
          _showCustomSnachBar(2, "Pensum cargado.");

          _ciclosData=onPensumResponse[1];
        }break;
        case 2:{
          _showCustomSnachBar(3, "Hubo un error al cargar pensum, si el error persiste, visite la página.");
        }break;
      }
    });
  }

  void _goLogin(){
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context)=>LoginState(
          title: "Login",
        ))
    );
  }

  void _showCustomSnachBar(int meaning,String text){
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            text,
            style: TextStyle(
                color: meaning==2?null:Colors.black
            ),
          ),
          backgroundColor: meaning==1?Colors.green:meaning==2?null:Colors.amber,
          action: SnackBarAction(
              textColor: !themeSingleton.isDark?Colors.white:null,
              label: "Ok",
              onPressed: (){
                scaffoldKey.currentState.hideCurrentSnackBar();
              }
          ),
        )
    );
  }

  Future<dynamic> _onRefresh() async{
    return await _getPensum();
  }
  
  List<Widget> _getCursos(List<Curso> _cursos){
    List<Widget> _cursosWidget=[];
    Table table=new Table();

    for(Curso item in _cursos){
      _cursosWidget.add(
        Card(
          color: themeSingleton.isDark?Colors.grey[800]:null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          elevation: themeSingleton.isDark?0:3,
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.nombre,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10.0),
                            bottom: Radius.circular(0.0)
                        ),
                        color: themeSingleton.isDark?Colors.grey[800]:Colors.amber
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2)
              ),
              Table(
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Text(
                          "Código",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: themeSingleton.isDark?Colors.white:null
                          ),
                        )
                      ),
                      TableCell(
                        child: Text(
                          "Requisito",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: themeSingleton.isDark?Colors.white:null
                          ),
                        )
                      )
                    ]
                  ),
                  TableRow(
                      children: [
                        Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                        Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                      ]
                  ),
                  TableRow(
                      children: [
                        TableCell(
                            child: Text(
                              item.codigo,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: themeSingleton.isDark?Colors.white:null
                              ),
                            )
                        ),
                        TableCell(
                          child: Text(
                            item.requisito,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: themeSingleton.isDark?Colors.white:null
                            )
                          )
                        )
                      ]
                  )
                ],
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 2)
              ),
            ],
          ),
        )
      );
    }
    
    return _cursosWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          brightness: themeSingleton.isDark?Brightness.dark:Brightness.light,
          accentColor: Colors.black26,
      ),
      child: Scaffold(
        backgroundColor: themeSingleton.isDark?Colors.black:null,
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: themeSingleton.isDark?Colors.black:Colors.amber,
          title: Text(
            widget.title,
          ),
        ),
        body: !_isLoading?RefreshIndicator(
          color: Colors.amber,
          onRefresh: (){
            return _onRefresh();
          },
          child: Scrollbar(
              child: ListView.builder(
                itemBuilder: (context,index){
                  return Card(
                    color: themeSingleton.isDark?Color.fromRGBO(68, 68, 68, 1):null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    margin: EdgeInsets.all(5),
                    elevation: 3,
                    child: ExpansionTile(
                      title: Text(
                        _ciclosData[index].numero_ciclo.toUpperCase(),
                        //textAlign: TextAlign.center,
                        style: TextStyle(
                            color: themeSingleton.isDark?Colors.white:null
                        ),
                      ),
                      children: _getCursos(_ciclosData[index].cursos),
                    ),
                  );
                },
                itemCount: _ciclosData.length,
              )
          ),
        ):Center(
          child: Container(
            width: 60.0,
            height: 60.0,
            child: CircularProgressIndicator(
              strokeWidth: 5.0,
              valueColor: AlwaysStoppedAnimation(Colors.amber),
            ),
          ),
        ),
      ),
    );
  }

}