import 'package:flutter/material.dart';
import 'package:notas_cliente/Model/Nota.dart';
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
  SharedPreferences _appStorage;


  @override
  void initState() {
    _initAppStorage();
    super.initState();
  }

  Future<dynamic> _initAppStorage() async {
    _appStorage=await SharedPreferences.getInstance();
    return true;
  }

  void _getGrades(){
    Map<String,String> cookies=new Map();

    for(String key in _appStorage.getKeys()){
      cookies[key]=_appStorage.get(key);
    }

    _notasViewModel.getGrades(_selectedSemestre, _selectedAnio, cookies).then((onValue){
      if(onValue[0]==1){
        //print(onValue[1]);
      }else{
        //print(onValue[1]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Color.fromRGBO(53, 56, 84, 1),
              expandedHeight: 225.0,
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
                          /*Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[

                            ],
                          )*/
                          FlatButton(
                            shape: StadiumBorder(
                                side: BorderSide(
                                    color: Colors.white
                                )
                            ),
                            onPressed: (){
                              _getGrades();
                            },
                            child: Text("Ver notas")
                          ),
                        ],
                      )
                  )
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          backgroundColor: Colors.black,
          onRefresh: ()async{
            return await Future.delayed(Duration(milliseconds: 1000));
          },
          child: Scrollbar(
              child: ListView.builder(
                  itemBuilder: (context,index){
                  }
              )
          ),
        ),
      ),
    );
  }
}