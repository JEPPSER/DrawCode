import 'DiagramObject.dart';
import 'Class.dart';
import 'Association.dart';
import 'Package.dart';

class ClassDiagramParser {

  List<DiagramObject> parse(String string){
    List<DiagramObject> list = new List<DiagramObject>();
    List<String> lines = string.split("\n");
    for(int i = 1; i < lines.length; i++){
      if(lines[i].startsWith("Class ")){
        initClass(list, lines[i], i, ClassType.CLASS);
      } else if(lines[i].startsWith("Enum ")){
        initClass(list, lines[i], i, ClassType.ENUM);
      } else if(lines[i].startsWith("Interface ")){
        initClass(list, lines[i], i, ClassType.INTERFACE);
      } else if(lines[i].startsWith("Package ")){
        package(list, lines[i], i);
      } else if(lines[i].contains(" add ")){
        add(list, lines[i], i);
      } else if(lines[i].contains("- ->")){
        dependency(list, lines[i], i);
      } else if(lines[i].contains("-|>")){
        inheritance(list, lines[i], i);
      } else if(lines[i].contains("- -|>")){
        realization(list, lines[i], i);
      } else if(lines[i].contains(")-(")){
        association(list, lines[i], i);
      } else if(lines[i].contains(")->(")){
        dAssociation(list, lines[i], i);
      } else if(lines[i].contains(")<>-(")){
        aggregation(list, lines[i], i);
      } else if(lines[i].contains(")<#>-(")){
        composition(list, lines[i], i);
      }
    }
    return list;
  }

  void package(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" ");
    if(parts.length == 2 && !line.contains(".")){
      for(int i = 0; i < list.length; i++){
        if(parts[1] == list[i].name){
          print("ERROR: variable name already exists\nline: $lineNumber");
          return;
        }
      }
      Package p = new Package();
      p.name = parts[1];
      list.add(p);
    } else {
      print("ERROR: invalid variable name\nline: $lineNumber");
    }
  }

  void composition(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(")<#>-(");
    String from = parts[0].split("(")[1];
    String to = parts[1].split(")")[0];
    int a = -1;
    int b = -1;
    for(int i = 0; i < list.length; i++){
      if(list[i].name == parts[0].split("(")[0]){
        a = i;
      } else if(list[i].name == parts[1].split(")")[1]){
        b = i;
      }
    }
    if(a != -1 && b != -1){
      if(list[a] is Class && list[b] is Class){
        Class c = list[a];
        Association ass = new Association();
        ass.from = from;
        ass.to = to;
        ass.object = list[b];
        c.compositions.add(ass);
      } else {
        print("ERROR: invalid variable type\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void aggregation(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(")<>-(");
    String from = parts[0].split("(")[1];
    String to = parts[1].split(")")[0];
    int a = -1;
    int b = -1;
    for(int i = 0; i < list.length; i++){
      if(list[i].name == parts[0].split("(")[0]){
        a = i;
      } else if(list[i].name == parts[1].split(")")[1]){
        b = i;
      }
    }
    if(a != -1 && b != -1){
      if(list[a] is Class && list[b] is Class){
        Class c = list[a];
        Association ass = new Association();
        ass.from = from;
        ass.to = to;
        ass.object = list[b];
        c.aggregations.add(ass);
      } else {
        print("ERROR: invalid variable type\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void dAssociation(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(")->(");
    String from = parts[0].split("(")[1];
    String to = parts[1].split(")")[0];
    int a = -1;
    int b = -1;
    for(int i = 0; i < list.length; i++){
      if(list[i].name == parts[0].split("(")[0]){
        a = i;
      } else if(list[i].name == parts[1].split(")")[1]){
        b = i;
      }
    }
    if(a != -1 && b != -1){
      if(list[a] is Class && list[b] is Class){
        Class c = list[a];
        Association ass = new Association();
        ass.from = from;
        ass.to = to;
        ass.object = list[b];
        c.dAssociations.add(ass);
      } else {
        print("ERROR: invalid variable type\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void association(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(")-(");
    String from = parts[0].split("(")[1];
    String to = parts[1].split(")")[0];
    int a = -1;
    int b = -1;
    for(int i = 0; i < list.length; i++){
      if(list[i].name == parts[0].split("(")[0]){
        a = i;
      } else if(list[i].name == parts[1].split(")")[1]){
        b = i;
      }
    }
    if(a != -1 && b != -1){
      if(list[a] is Class && list[b] is Class){
        Class c = list[a];
        Association ass = new Association();
        ass.from = from;
        ass.to = to;
        ass.object = list[b];
        c.associations.add(ass);
      } else {
        print("ERROR: invalid variable type\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void realization(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split("- -|>");
    int a = -1;
    int b = -1;
    for(int i = 0; i < list.length; i++){
      if(list[i].name == parts[0]){
        a = i;
      } else if(list[i].name == parts[1]){
        b = i;
      }
    }
    if(a != -1 && b != -1){
      if(list[a] is Class && list[b] is Class){
        Class c = list[a];
        c.realizations.add(list[b]);
      } else {
        print("ERROR: invalid variable type\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void inheritance(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split("-|>");
    int a = -1;
    int b = -1;
    for(int i = 0; i < list.length; i++){
      if(list[i].name == parts[0]){
        a = i;
      } else if(list[i].name == parts[1]){
        b = i;
      }
    }
    if(a != -1 && b != -1){
      if(list[a] is Class && list[b] is Class){
        Class c = list[a];
        c.inheritances.add(list[b]);
      } else {
        print("ERROR: invalid variable type\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void dependency(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split("- ->");
    int a = -1;
    int b = -1;
    for(int i = 0; i < list.length; i++){
      if(list[i].name == parts[0]){
        a = i;
      } else if(list[i].name == parts[1]){
        b = i;
      }
    }
    if(a != -1 && b != -1){
      if(list[a] is Class && list[b] is Class){
        Class c = list[a];
        c.dependencies.add(list[b]);
      } else {
        print("ERROR: invalid variable type\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void add(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" add ");
    for(int i = 0; i < list.length; i++){
      if(list[i].name == parts[0] && list[i] is Class){
        Class c = list[i];
        c.members.add(parts[1]);
        break;
      } else if(list[i].name == parts[0] && list[i] is Package){
        Package p = list[i];
        for(int j = 0; j < list.length; j++){
          if(list[j].name == parts[1] && list[j] is Class && j != i){
            Class c = list[j];
            p.classes.add(c);
            break;
          }
        }
      }
    }
  }

  void initClass(List<DiagramObject> list, String line, int lineNumber, ClassType type){
    List<String> parts = line.split(" ");
    if(parts.length == 2 && !line.contains(".")){
      for(int i = 0; i < list.length; i++){
        if(parts[1] == list[i].name){
          print("ERROR: variable name already exists\nline: $lineNumber");
          return;
        }
      }
      Class c = new Class();
      c.name = parts[1];
      c.type = type;
      list.add(c);
    } else {
      print("ERROR: invalid variable name\nline: $lineNumber");
    }
  }
}