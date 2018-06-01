import 'DiagramObject.dart';
import 'Class.dart';

class Package extends DiagramObject{

  List<Class> classes;

  Package(){
    x = 0;
    y = 0;
    width = 0;
    height = 0;
  }
}