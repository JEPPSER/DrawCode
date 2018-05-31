import 'DiagramObject.dart';
import 'UseCase.dart';
import 'dart:math';

class System extends DiagramObject {  
  String text;
  List<UseCase> useCases;

  System(){
    useCases = new List<UseCase>();
    x = 250;
    y = 50;
    width = 400;
    height = 450;
  }
}