import 'package:flutter/material.dart';
import 'package:notas_cliente/Utils/ThemeSingleton.dart';

class ThemeItem{
  int themeIndex;
  String themeName;
  bool selected;

  ThemeItem(this.themeIndex, this.themeName, this.selected);


}

typedef void OnChangeTheme(ThemeItem themeItem);

class ThemeList extends StatefulWidget{
  ThemeList({
    Key key,
    this.onChangeTheme
  }):super(key:key);

  OnChangeTheme onChangeTheme;

  @override
  State<StatefulWidget> createState() {
    return ThemeListWidget();
  }
}

class ThemeListWidget extends State<ThemeList>{
  List<ThemeItem> themes=[
    new ThemeItem(1, "Oscuro", themeSingleton.isDark?true:false),
    new ThemeItem(2, "Claro", themeSingleton.isDark?false:true)
  ];

  void unselectExcept(int index){
    for(int count=0;count<themes.length;count++){
      if(count!=index) themes[count].selected=false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context,index){
        return Theme(
          data: ThemeData(
            brightness: themeSingleton.isDark?Brightness.dark:null
          ),
          child: CheckboxListTile(
              activeColor: Colors.deepOrangeAccent,
              value: themes[index].selected,
              title: Text(
                themes[index].themeName,
              ),
              onChanged: (newValue){
                if(newValue){
                  themes[index].selected=newValue;
                  widget.onChangeTheme(themes[index]);

                  unselectExcept(index);
                  setState(() {
                  });
                }
              }
          )
        );
      },
      itemCount: themes.length,

    );
  }

}

