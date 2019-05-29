abstract class IHorarioSource{
  Future<dynamic> getHorario(Map<String,String> cookies,String url);
}