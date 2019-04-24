import 'package:flutter/material.dart';
import 'package:notas_cliente/Model/Nota.dart';
import 'package:notas_cliente/Utils/ConnectionStatusSingleton.dart';
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
  int _selectedSemestre;
  int _selectedAnio;
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

            }break;
            case 1:{

            }break;
            case 2:{

            }break;
            case 100:{
              _showCustomSnachBar(3, onValue[1]);
            }break;
            case 200:{
              _showCustomSnachBar(3, onValue[1]);
              notasData=onValue[2];

              setState(() {
              });
            }break;
            case 300:{
              _showCustomSnachBar(3, onValue[1]);
            }break;
          }

          if(onValue[0]==1){
            print(onValue);
          }else{
            print(onValue);
          }
        });
      }else{
        _showCustomSnachBar(2, "No hay conexion a internet.");
      }
    });
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color.fromRGBO(53, 56, 84, 1),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    hint: Text(
                                      "Seleccione semestre",
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
                                      "Seleccione año",
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
            padding: EdgeInsets.symmetric(vertical: 0.0),
            itemBuilder: (context,index){
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero
                ),
                margin: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        notasData[index].nombreCurso,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          padding: EdgeInsets.all(18.0),
                          shape: CircleBorder(),
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
                        FlatButton(
                          padding: EdgeInsets.all(18.0),
                          shape: CircleBorder(),
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
                        FlatButton(
                            padding: EdgeInsets.all(18.0),
                            shape: CircleBorder(),
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
                        FlatButton(
                            padding: EdgeInsets.all(18.0),
                            shape: CircleBorder(),
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