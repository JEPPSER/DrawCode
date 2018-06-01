import 'DiagramObject.dart';
import 'Association.dart';

enum ClassType {CLASS, INTERFACE, ENUM}

class Class extends DiagramObject{
  ClassType type;
  List<Class> inheritances;
  List<Class> dependencies;
  List<Class> realizations;
  List<Association> associations;
  List<Association> dAssociations;
  List<Association> aggregations;
  List<Association> compositions;

  List<String> members;

  Class(){
    inheritances = new List<Class>();
    dependencies = new List<Class>();
    realizations = new List<Class>();
    associations = new List<Association>();
    dAssociations = new List<Association>();
    aggregations = new List<Association>();
    compositions = new List<Association>();
    members = new List<String>();
  }
}