import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: ()async{
          return await Future.delayed(Duration(milliseconds: 2000));
        },
        child: Scrollbar(
          child: ListView.builder(
            itemBuilder: (context,index){

            }
          )
        )
      ),
    );
  }
}