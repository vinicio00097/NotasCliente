import 'package:flutter/material.dart';
import 'package:notas_cliente/Model/Curso.dart';

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
  List<Curso> _horarioData=[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.purple[400],
      ),
      body: RefreshIndicator(
        color: Colors.purple[400],
        onRefresh: ()async{
          return Future.delayed(Duration(milliseconds: 2000));
        },
        child: Scrollbar(
          child: ListView.builder(
            itemBuilder: (context,index){

            },
            itemCount: _horarioData.length,
          ),
        ),
      ),
    );
  }

}