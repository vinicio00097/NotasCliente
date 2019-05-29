abstract class IPensumSource{
  Future<dynamic> getPensum(Map<String,String> cookies,String url);
}