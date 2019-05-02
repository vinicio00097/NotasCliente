import 'package:notas_cliente/Model/Nota.dart';
import 'package:notas_cliente/Service/NotasSource.dart';
import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';
import 'package:notas_cliente/Utils/ErrorsDefinition.dart';

class NotasViewModel{
  NotasSource _notasSource=new NotasSource();

  Future<dynamic> getGrades(int semestre,int anio,Map<String,String> cookies) async{
    try{
      List<Object> response=await _notasSource.getGrades(semestre, anio, cookies);

      if(response[0]==1){
        Document document=parse(response[1]);
        Element notesTable=document.querySelector("#marks");
        Element errorMsg=document.querySelector(".errormsg");

        if(notesTable==null){
          return ServiceErrors.No_Inscrito;
        }else{
          List<Nota> notas=[];

          if(errorMsg!=null){
            if(errorMsg.text.contains("insolvente")){
              
              return ServiceErrors.Insolvente;
            }else{
              return ServiceErrors.Unknown_Error;
            }
          }else{
            List<Element> rowGrades=notesTable.getElementsByTagName("tbody")[0].getElementsByTagName("tr");

            for(Element rowGrade in rowGrades){
              List<Element> dataRow=rowGrade.getElementsByTagName("td");

              notas.add(new Nota(
                  nombreCurso: dataRow[0].text,
                  parcialUno: dataRow[1].text,
                  parcialDos: dataRow[2].text,
                  actividades: dataRow[3].text,
                  examenFinal: dataRow[4].text,
                  notaFinal: dataRow[5].text
              ));
            }

            return [1,notas];
          }
        }
      }else{
        return [0,response[1]];
      }
    }catch(e){
      print(e);
      return [2,e];
    }
  }
}