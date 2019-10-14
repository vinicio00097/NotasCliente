import 'package:flutter/material.dart';
import 'package:notas_cliente/Utils/ThemeSingleton.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ThemeListWidget.dart';

class ThemeDialog extends StatefulWidget{
  ThemeDialog({
    Key key,
    this.title,
    this.onChangeTheme
  });

  OnChangeTheme onChangeTheme;
  final title;

  @override
  State<StatefulWidget> createState() {
    return ThemeDialogWidget();
  }
}

class ThemeDialogWidget extends State<ThemeDialog>{
  SharedPreferences appData;

  @override
  void initState() {
    initAppData();
    super.initState();
  }

  initAppData() async {
    appData=await SharedPreferences.getInstance();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: themeSingleton.isDark?Color.fromRGBO(68, 68, 68, 1):null,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(15.0)
          )
      ),
      title: Text(
        "Administrador de temas",
        style: TextStyle(
          color: themeSingleton.isDark?Colors.white:null
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Theme(
              data: ThemeData(
                brightness: themeSingleton.isDark?Brightness.dark:null
              ),
              child: SwitchListTile(
                  title: Text("Automático"),
                  value: !themeSingleton.isThemeManagerActive,
                  onChanged: (newValue){
                    if(newValue){
                      appData.setBool("themeManagerActive", !newValue);
                      themeSingleton.isThemeManagerActive=!themeSingleton.isThemeManagerActive;

                      Navigator.pop(context,true);
                    }
                  }
              ),
            ),
            Container(
              height: 150,
              child: ThemeList(
                onChangeTheme: (theme){
                  if(theme.themeName=="Oscuro") {
                    themeSingleton.isDark=true;
                  }else{
                    themeSingleton.isDark=false;
                  }
                  widget.onChangeTheme(theme);

                  setState(() {
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

}