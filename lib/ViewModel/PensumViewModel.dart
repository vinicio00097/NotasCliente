import 'package:notas_cliente/Service/PensumSource.dart';
import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';

class PensumViewModel{
  PensumSource _pensumSource=new PensumSource();

  Future<dynamic> getGrades(Map<String,String> cookies) async{
    try{
      List<Object> response=await _pensumSource.getPensum(cookies);

      if(response[0]==1){
        Document document=parse(response[1]);
      }else{
        return [0,response[1]];
      }
    }catch(e){
      print(e);
      return [2,e];
    }
  }
}