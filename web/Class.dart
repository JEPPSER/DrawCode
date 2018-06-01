import 'DiagramObject.dart';
import 'Association.dart';

enum ClassType {CLASS, INTERFACE, ENUM}

class Class extends DiagramObject{
  ClassType type;
  List<Class> inheritances;
  List<Class> dependencies;
  List<Class> realization;
  List<Association> associations;
  List<Association> dAssociations;
  List<Association> aggregations;
  List<Association> composition;

  List<String> members;

  Class(){
    inheritances = new List<Class>();
    dependencies = new List<Class>();
    realization = new List<Class>();
    associations = new List<Association>();
    dAssociations = new List<Association>();
    aggregations = new List<Association>();
    composition = new List<Association>();
    members = new List<String>();
  }
}