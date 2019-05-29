import 'package:notas_cliente/Model/Curso.dart';
import 'package:notas_cliente/Service/HorarioSource.dart';
import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';

class HorarioViewModel{
  HorarioSource _horarioSource=new HorarioSource();

  Future<dynamic> getHorario(Map<String,String> cookies,String url) async{
    try{
      List<Object> response=await _horarioSource.getHorario(cookies,url);

      if(response[0]==1){
        List<Curso> _cursos=[];
        Document document=parse(response[1]);
        Element tableHorario=document.querySelector(".data-visualization");

        for(Element rowClass in tableHorario.querySelector("tbody").querySelectorAll("tr")){
          List<Element> cursoCellsData=rowClass.querySelectorAll("td");

          _cursos.add(
              new Curso(
                nombre: cursoCellsData[0].text.trim(),
                seccion: cursoCellsData[1].text.trim(),
                salon: cursoCellsData[2].text.trim(),
                horario: cursoCellsData[3].text.trim()
              )
          );
        }

        return [1,_cursos];
      }else{
        return [0,response[1]];
      }
    }catch(e){
      print(e);
      return [2,e];
    }
  }
}