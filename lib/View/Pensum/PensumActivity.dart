import 'package:flutter/material.dart';
import 'package:notas_cliente/Model/PensumItem.dart';
import 'package:notas_cliente/ViewModel/PensumViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PensumState extends StatefulWidget{
  PensumState({
    Key key,
    this.title
  }):super(key:key);

  final title;
  @override
  State<StatefulWidget> createState() {
    return PensumWidget();
  }
}

class PensumWidget extends State<PensumState>{
  List<PensumItem> _clasesData=[];
  PensumViewModel _pensumViewModel=new PensumViewModel();
  Map<String,String> _cookies=new Map();
  final scaffoldKey=GlobalKey<ScaffoldState>();
  SharedPreferences _appStorage;


  @override
  void initState() {
    _initAppStorage().then((onValue){
      _pensumViewModel.getGrades(_cookies).then((onValue2){

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: ()async{
          return Future.delayed(Duration(milliseconds: 2000));
        },
        child: Scrollbar(
          child: ListView.builder(
            itemBuilder: (context,index){

            },
            itemCount: _clasesData.length,
          )
        ),
      ),
    );
  }

}