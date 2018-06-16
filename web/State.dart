import 'DiagramObject.dart';
import 'Arrow.dart';

enum StateType {START, END, NORMAL}

class State extends DiagramObject{

  List<Arrow> connections;
  StateType type;

  State(){
    connections = new List<Arrow>();
    width = 80;
    height = 80;
  }
}