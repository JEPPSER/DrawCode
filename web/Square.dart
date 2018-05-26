import 'DiagramObject.dart';

enum SquareType {STEP, START, END, IO_BOX, DOCUMENT}

class Square extends DiagramObject{
  String text;
  List<DiagramObject> connections;
  SquareType type;

  Square(){
    connections = new List<DiagramObject>();
    width = 80;
    height = 60;
  }
}