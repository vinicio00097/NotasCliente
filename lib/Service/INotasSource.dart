abstract class INotasSource{
  Future<dynamic> getGrades(int semestre,int anio,Map<String,String> cookies,String url);
}