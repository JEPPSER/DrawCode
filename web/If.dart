import 'DiagramObject.dart';
import 'Arrow.dart';
import 'dart:math';

class If extends DiagramObject {
  String text;
  Arrow yes;
  Arrow no;
  Point yesPoint;
  Point noPoint;

  If(){
    width = 60;
    height = 60;
  }
}