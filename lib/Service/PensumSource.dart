import 'package:http/http.dart';
import 'package:notas_cliente/Service/IPensumSource.dart';

class PensumSource implements IPensumSource{

  @override
  Future getPensum(Map<String, String> cookies,String url) async {
    try{
      StringBuffer stringBuffer=new StringBuffer();
      cookies.forEach((key,value){
        stringBuffer.write(key.replaceAll("\"", "")+"="+value.replaceAll("\"", "")+";");
      });

      Response response=await get(
          "https://apps.umg.edu.gt/pensum",
          headers: {
            "Cookie":stringBuffer.toString(),
            "Content-Type":"application/x-www-form-urlencoded"
          },
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