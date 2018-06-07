import 'DiagramObject.dart';
import 'Arrow.dart';

enum SquareType {STEP, START, END, IO_BOX, DOCUMENT}

class Square extends DiagramObject{
  String text;
  List<Arrow> connections;
  SquareType type;

  Square(){
    connections = new List<Arrow>();
    width = 80;
    height = 60;
  }
}