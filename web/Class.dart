import 'DiagramObject.dart';
import 'Association.dart';
import 'Arrow.dart';

enum ClassType {CLASS, INTERFACE, ENUM}

class Class extends DiagramObject{
  ClassType type;
  List<Arrow> inheritances;
  List<Arrow> dependencies;
  List<Arrow> realizations;
  List<Association> associations;
  List<Association> dAssociations;
  List<Association> aggregations;
  List<Association> compositions;

  List<String> members;

  Class(){
    inheritances = new List<Arrow>();
    dependencies = new List<Arrow>();
    realizations = new List<Arrow>();
    associations = new List<Association>();
    dAssociations = new List<Association>();
    aggregations = new List<Association>();
    compositions = new List<Association>();
    members = new List<String>();
  }
}