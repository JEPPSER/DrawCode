import 'DiagramObject.dart';

class Square extends DiagramObject{
  String text;
  List<DiagramObject> connections;

  Square(){
    connections = new List<DiagramObject>();
  }
}