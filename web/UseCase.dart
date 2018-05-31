import 'DiagramObject.dart';

class UseCase extends DiagramObject {

  List<UseCase> extensions;
  List<UseCase> inclusions;
  String text;

  UseCase(){
    extensions = new List<UseCase>();
    inclusions = new List<UseCase>();
  }
}