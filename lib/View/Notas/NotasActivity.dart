import 'package:flutter/material.dart';
import 'package:notas_cliente/Model/Nota.dart';
import 'package:notas_cliente/Utils/ConnectionStatusSingleton.dart';
import 'package:notas_cliente/View/Login/LoginActivity.dart';
import 'package:notas_cliente/ViewModel/NotasViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotasState extends StatefulWidget{
  NotasState({
    Key key,
    this.title
  });

  final title;

  @override
  State<StatefulWidget> createState() {
    return NotasWidget();
  }
}

class NotasWidget extends State<NotasState>{
  List<int> _semestres=List.generate(8, (int index)=>index+1);
  List<int> _anios=List.generate(DateTime.now().year-2006, (int index)=>index+2007);
  int _selectedSemestre=DateTime.now().month>6?2:1;
  int _selectedAnio=DateTime.now().year;
  NotasViewModel _notasViewModel=new NotasViewModel();
  List<Nota> notasData=[];
  Map<String,String> _cookies=new Map();
  final scaffoldKey=GlobalKey<ScaffoldState>();
  SharedPreferences _appStorage;


  @override
  void initState() {
    _initAppStorage();
    super.initState();
  }

  Future<dynamic> _initAppStorage() async {
    _appStorage=await SharedPreferences.getInstance();

    for(String key in _appStorage.getKeys()){
      _cookies[key]=_appStorage.get(key);
    }

    return true;
  }

  Future<dynamic> _getGrades() async{
    await ConnectionStatusSingleton.verifyConnection().then((onValue) async {
      if(onValue){
        await _notasViewModel.getGrades(_selectedSemestre, _selectedAnio, _cookies).then((onValue){
          switch(onValue[0]){
            case 0:{
              _goLogin();
            }break;
            case 1:{
              notasData=onValue[1];

              setState(() {
              });

              _showCustomSnachBar(2, "Notas cargadas.");
            }break;
            case 2:{
              _showCustomSnachBar(3,"Ha ocurrido un error, si persiste, visite la página.");

              notasData.clear();

              setState(() {
              });
            }break;
            case 100:{
              notasData.clear();

              setState(() {
              });

              _showCustomSnachBar(3, onValue[1]);
            }break;
            case 200:{
              notasData.clear();

              setState(() {
              });

              _showCustomSnachBar(3, onValue[1]);
            }break;
            case 300:{
              notasData.clear();

              setState(() {
              });

              _showCustomSnachBar(3, onValue[1]);
            }break;
          }
        });
      }else{
        _showCustomSnachBar(2, "No hay conexion a internet.");
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

  void _loadingDialog(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return WillPopScope(
            child: Theme(
                data: ThemeData(
                    brightness: Brightness.light
                ),
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0)
                    )
                  ),
                  title: Text("Cargando..."),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      )
                    ],
                  ),
                )
            ),
            onWillPop: ()async=>false
        );
      }
    );
  }

  Future<dynamic> _onRefresh()async{
    if(_selectedSemestre!=null&&_selectedAnio!=null){
      return await _getGrades();
    }else{
      _showCustomSnachBar(2, "Debe seleccionar semestre y año para recargar notas.");
      return false;
    }
  }

  Color _getIndicatorColor(String examFinal,String notaFinal){
    RegExp _hasValidGrade=new RegExp("[0-9]+[\*]*");
    List<String> _flagsGrades=["NSP","SDE"];

    if(_hasValidGrade.hasMatch(examFinal)){
      if(int.tryParse(notaFinal)<61){
        return Colors.redAccent;
      }else{
        return Color.fromRGBO(53, 56, 84, 1);
      }
    }else{
      if(_flagsGrades.contains(examFinal)){
        return Colors.redAccent;
      }else{
        return Color.fromRGBO(53, 56, 84, 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      //backgroundColor: Color.fromRGBO(53, 56, 84, 1),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              elevation: 0.0,
              backgroundColor: Color.fromRGBO(53, 56, 84, 1),
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.title,
                    style: TextStyle(
                        fontSize: 25.0
                    ),
                  ),
                  background: Theme(
                      data: ThemeData(
                        brightness: Brightness.dark,
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 30.0,left: 45.0),
                            child: ListTile(
                              title: Text(
                                "Seleccione semestre y año para ver notas.",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5)
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  hint: Text(
                                    "Semestre",
                                  ),
                                  items: _semestres.map((number){
                                    return DropdownMenuItem<int>(
                                      child: Text(number.toString()),
                                      value: number,
                                    );
                                  }).toList(),
                                  onChanged: (value){
                                    _selectedSemestre=value;

                                    setState(() {
                                    });
                                  },
                                  value: _selectedSemestre,
                                )
                              ),
                              DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isDense: true,
                                    hint: Text(
                                      "Año",
                                    ),
                                    items: _anios.reversed.toList().map((number){
                                      return DropdownMenuItem<int>(
                                        child: Text(number.toString()),
                                        value: number,
                                      );
                                    }).toList(),
                                    onChanged: (value){
                                      _selectedAnio=value;

                                      setState(() {
                                      });
                                    },
                                    value: _selectedAnio,
                                  )
                              ),
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 5)
                          ),
                          FlatButton(
                            shape: StadiumBorder(
                              side: BorderSide(
                                width: 1.5,
                                color: Colors.white,
                              )
                            ),
                            onPressed: _selectedSemestre!=null&&_selectedAnio!=null?(){
                              _loadingDialog();

                              _getGrades().then((onValue){
                                Navigator.pop(context);
                              });
                            }:null,
                            child: Text("Ver notas")
                          ),
                        ],
                      )
                  )
              ),
            ),
          ];
        },
        body: Scrollbar(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 5.0),
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
                                  notasData[index].nombreCurso,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20.0,
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
                            color: _getIndicatorColor(notasData[index].examenFinal, notasData[index].notaFinal)
                          ),
                        ),

                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ButtonTheme(
                          padding: EdgeInsets.all(18),
                          minWidth: 50,
                          shape: CircleBorder(),
                          child: FlatButton(
                            onPressed: (){

                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("P1"),
                                Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                                Text(notasData[index].parcialUno)
                              ],
                            )
                          ),
                        ),
                        ButtonTheme(
                          padding: EdgeInsets.all(18),
                          minWidth: 50,
                          shape: CircleBorder(),
                          child: FlatButton(
                              onPressed: (){

                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("P2"),
                                  Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                                  Text(notasData[index].parcialDos)
                                ],
                              )
                          ),
                        ),
                        ButtonTheme(
                          padding: EdgeInsets.all(18),
                          minWidth: 50,
                          shape: CircleBorder(),
                          child: FlatButton(
                              onPressed: (){

                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Act."),
                                  Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                                  Text(notasData[index].actividades)
                                ],
                              )
                          ),
                        ),
                        ButtonTheme(
                          padding: EdgeInsets.all(18),
                          minWidth: 50,
                          shape: CircleBorder(),
                          child: FlatButton(
                              onPressed: (){

                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Final"),
                                  Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                                  Text(notasData[index].examenFinal)
                                ],
                              )
                          ),
                        ),
                        ButtonTheme(
                          padding: EdgeInsets.all(18),
                          minWidth: 50,
                          shape: CircleBorder(),
                          child: FlatButton(
                              onPressed: (){

                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Nota"),
                                  Padding(padding: EdgeInsets.symmetric(vertical: 2)),
                                  Text(notasData[index].notaFinal)
                                ],
                              )
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
            itemCount: notasData.length,
          )
        ),
      ),
    );
  }
}