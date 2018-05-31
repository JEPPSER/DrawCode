import 'DiagramObject.dart';
import 'UseCase.dart';

class System extends DiagramObject {  
  String text;
  List<UseCase> useCases;

  System(){
    useCases = new List<UseCase>();
  }
}