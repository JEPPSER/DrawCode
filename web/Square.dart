import 'DiagramObject.dart';

enum SquareType {STEP, START, END, IO_BOX, DOCUMENT}

class Square extends DiagramObject{
  String text;
  List<DiagramObject> connections;
  SquareType type;

  Square(){
    connections = new List<DiagramObject>();
    width = 100;
    height = 50;
  }
}