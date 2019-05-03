import 'package:flutter/material.dart';
import 'package:notas_cliente/Model/Curso.dart';
import 'package:notas_cliente/Utils/ConnectionStatusSingleton.dart';
import 'package:notas_cliente/View/Login/LoginActivity.dart';
import 'package:notas_cliente/ViewModel/HorarioViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HorarioState extends StatefulWidget{
  HorarioState({
    Key key,
    this.title
  }):super(key:key);

  final title;
  @override
  State<StatefulWidget> createState() {
    return HorarioWidget();
  }
}

class HorarioWidget extends State<HorarioState>{
  bool _isLoading=true;
  List<Curso> _horarioData=[];
  HorarioViewModel _horarioViewModel=new HorarioViewModel();
  Map<String,String> _cookies=new Map();
  final scaffoldKey=GlobalKey<ScaffoldState>();
  SharedPreferences _appStorage;

  @override
  void initState() {
    _initAppStorage().then((onValue){
      ConnectionStatusSingleton.verifyConnection().then((internetStatus){
        if(internetStatus){
          _getHorario().then((onHorarioResponse){
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
    super.initState();
  }

  Future<dynamic> _initAppStorage() async {
    _appStorage=await SharedPreferences.getInstance();

    for(String key in _appStorage.getKeys()){
      _cookies[key]=_appStorage.get(key);
    }

    return true;
  }

  Future<dynamic> _getHorario()async{
    await _horarioViewModel.getHorario(_cookies).then((onValue){
      switch(onValue[0]){
        case 0:{
          _goLogin();
        }break;
        case 1:{
          _showCustomSnachBar(2, "Horario cargado.");

          _horarioData=onValue[1];
        }break;
        case 2:{
          _showCustomSnachBar(3, "Hubo un error al cargar horario, si el error persiste, visite la página.");
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
        )
    );
  }

  Future<dynamic> _onRefresh() async{
    return await _getHorario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.purple[400],
      ),
      body: !_isLoading?RefreshIndicator(
        color: Colors.purple[400],
        onRefresh: (){
          return _onRefresh();
        },
        child: Scrollbar(
          child: ListView.builder(
            itemBuilder: (context,index){
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                margin: EdgeInsets.all(5),
                elevation: 4,
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
                                  _horarioData[index].nombre,
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
                              color: Colors.purple[400]
                          ),
                        ),

                      ],
                    ),
                    Table(
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                                child: Text(
                                  "Salón",
                                  textAlign: TextAlign.center,
                                )
                            ),
                            TableCell(
                                child: Text(
                                  "Sección",
                                  textAlign: TextAlign.center,
                                )
                            ),
                            TableCell(
                                child: Text(
                                  "Horario",
                                  textAlign: TextAlign.center,
                                )
                            )
                          ]
                        ),
                        TableRow(
                            children: [
                              Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                              Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                              Padding(padding: EdgeInsets.symmetric(vertical: 2))
                            ]
                        ),
                        TableRow(
                            children: [
                              TableCell(
                                  child: Text(
                                    _horarioData[index].salon,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54
                                    ),
                                  )
                              ),
                              TableCell(
                                  child: Text(
                                    _horarioData[index].seccion,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54
                                    ),
                                  )
                              ),
                              TableCell(
                                  child: Text(
                                    _horarioData[index].horario,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54
                                    ),
                                  )
                              )
                            ]
                        )
                      ],
                    )
                  ],
                ),
              );
            },
            itemCount: _horarioData.length,
          ),
        ),
      ):Center(
        child: Container(
          width: 60.0,
          height: 60.0,
          child: CircularProgressIndicator(
            strokeWidth: 5.0,
            valueColor: AlwaysStoppedAnimation(Colors.purple[400]),
          ),
        ),
      ),
    );
  }

}