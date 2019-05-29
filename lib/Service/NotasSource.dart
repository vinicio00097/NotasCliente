import 'package:http/http.dart';
import 'package:notas_cliente/Service/INotasSource.dart';

class NotasSource implements INotasSource{

  @override
  Future getGrades(int semestre,int anio,Map<String,String> cookies,String url) async {
    try{
      StringBuffer stringBuffer=new StringBuffer();
      cookies.forEach((key,value){
        stringBuffer.write(key.replaceAll("\"", "")+"="+value.replaceAll("\"", "")+";");
      });

      Response response=await post(
          url==null?"https://apps.umg.edu.gt/calificaciones2018?v-n":url+"?v-n",
          headers: {
            "Cookie":stringBuffer.toString(),
            "Content-Type":"application/x-www-form-urlencoded"
          },
          body: "c=$semestre&y=$anio"
      );

      print(response.statusCode);

      if(response.statusCode==200){
        return [1,response.body];
      }else{
        return [0,response.body];
      }
    }catch(e){
      print(e);
      return [2];
    }
  }

}