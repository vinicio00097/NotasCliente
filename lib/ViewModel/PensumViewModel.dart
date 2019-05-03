import 'package:notas_cliente/Model/Curso.dart';
import 'package:notas_cliente/Model/PensumItem.dart';
import 'package:notas_cliente/Service/PensumSource.dart';
import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';

class PensumViewModel{
  PensumSource _pensumSource=new PensumSource();

  Future<dynamic> getPensum(Map<String,String> cookies) async{
    try{
      List<Object> response=await _pensumSource.getPensum(cookies);

      if(response[0]==1){
        List<PensumItem> _ciclos=[];
        Document document=parse(response[1]);
        List<Element> clasesItems=document.querySelector("#right-panel").querySelector(".block").getElementsByTagName("div");

        for(Element item in clasesItems){
          Element label=item.querySelector("label");
          Element tableItem=item.querySelector("table");
          List<String> labelItems=label.text.toString().split(RegExp("[\\.]+[a-z]+[\\s]{1}"));

          List<Curso> _cursos=[];
          for(Element rowClass in tableItem.querySelector("tbody").querySelectorAll("tr")){
            List<Element> cursoCellsData=rowClass.querySelectorAll("td");

            _cursos.add(
              new Curso(
                codigo: cursoCellsData[0].text.trim(),
                nombre: cursoCellsData[1].text.trim(),
                requisito: cursoCellsData[2].text.trim()
              )
            );
          }

          _ciclos.add(new PensumItem(
            numero_ciclo: labelItems[1]+" "+labelItems[0],
            cursos: _cursos
          ));
        }

        return [1,_ciclos];
      }else{
        return [0,response[1]];
      }
    }catch(e){
      print(e);
      return [2,e];
    }
  }
}