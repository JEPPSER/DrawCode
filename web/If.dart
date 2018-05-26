import 'DiagramObject.dart';

class If extends DiagramObject {
  String text;
  DiagramObject yes;
  DiagramObject no;

  If(){
    width = 60;
    height = 60;
  }
}