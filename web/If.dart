import 'DiagramObject.dart';
import 'Arrow.dart';

class If extends DiagramObject {
  String text;
  Arrow yes;
  Arrow no;

  If(){
    width = 60;
    height = 60;
  }
}