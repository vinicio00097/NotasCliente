import 'package:flutter/material.dart';

class retryState extends StatefulWidget{
  retryState({
    Key key,
    this.onRetryClick
  }):super(key:key);

  VoidCallback onRetryClick;
  retryWidget createState()=>new retryWidget();
}

class retryWidget extends State<retryState>{
  int isLoaded=2;

  @override
  @mustCallSuper
  void initState(){

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Image(
              image: AssetImage("assets/offline.gif")
          ),
          width: 150.0,
          height: 150.0,
        ),
        Container(
          width: 160.0,
          height: 40.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              this.isLoaded==2?RaisedButton(
                onPressed: (){
                  widget.onRetryClick();
                },
                child: Text("Reintentar"),
              ):CircularProgressIndicator(
                strokeWidth: 5.0,
              )
            ],
          ),
        )
      ],
    );
  }
}