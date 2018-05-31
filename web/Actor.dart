import 'DiagramObject.dart';
import 'UseCase.dart';

class Actor extends DiagramObject {
  
  List<UseCase> connections;
  List<Actor> implementations;
  String text;

  Actor(){
    connections = new List<UseCase>();
    implementations = new List<Actor>();
  }
}