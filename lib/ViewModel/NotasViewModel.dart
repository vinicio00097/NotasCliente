import 'package:notas_cliente/Service/NotasSource.dart';
import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';

class NotasViewModel{
  NotasSource _notasSource=new NotasSource();

  Future<dynamic> getGrades(int semestre,int anio,Map<String,String> cookies) async{
    try{
      List<Object> response=await _notasSource.getGrades(semestre, anio, cookies);

      if(response[0]==1){
        Document document=parse(response[1]);
        print(document.documentElement);
        return [1,response[1]];
      }else{
        return [0,response[1]];
      }
    }catch(e){
      return [2,e];
    }
  }
}