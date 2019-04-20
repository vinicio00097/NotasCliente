import 'package:flutter/material.dart';

class PasswordState extends StatefulWidget{
  PasswordState({
    Key key

  }):super(key:key);

  @override
  State<StatefulWidget> createState() {
    return PasswordWidget();
  }
}

class PasswordWidget extends State<PasswordState>{
  bool _currentState=false;
  Icon _currentIcon=Icon(Icons.visibility_off);
  String _currentTooltip="Mostrar contraseña";

  @override
  void initState() {
    super.initState();
  }

  void _onChangeVisibility(){
    if(_currentState){
      _currentIcon=Icon(Icons.visibility);
      _currentTooltip="Ocultar contraseña";
      _currentState=!_currentState;
    }else{
      _currentIcon=Icon(Icons.visibility_off);
      _currentTooltip="Mostrar contraseña";
      _currentState=!_currentState;
    }

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            TextFormField(
              //controller: mountController,
              obscureText: _currentState,
              decoration: InputDecoration(
                hintText: "Ingrese contraseña",
                labelText: "Contraseña",
                //contentPadding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 15.0),
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                  //gapPadding:5.0,
                ),
              ),
              keyboardType: TextInputType.text,
              style: const TextStyle(
                  letterSpacing: 1.0,
                  fontSize: 20.0,
                  color: Colors.black
              ),
              validator: (text){
                if(text.isEmpty){
                  return "Campo obligatorio.";
                }else{
                  if(!RegExp("^(((\\d)+([.](\\d)+|(\\d)*)))\$").hasMatch(text)){
                    return "Campo unicamente numerico.";
                  }
                }},
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  //splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: (){

                  },
                  child: Text(
                    "Olvidó contraseña ?",
                    style: TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                )
              ],
            )
          ], 
        ),
        Positioned(
          child: IconButton(
            tooltip: _currentTooltip,
            icon: _currentIcon,
            onPressed: _onChangeVisibility
          ),
          right: 0.0,
          top: 17.0,
        ),
      ],
    );
  }

}