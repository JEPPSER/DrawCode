import 'DiagramObject.dart';
import 'System.dart';
import 'Actor.dart';
import 'UseCase.dart';

class UseCaseParser {

  List<DiagramObject> parse(String string){
    List<DiagramObject> list = new List<DiagramObject>();
    List<String> lines = string.split("\n");

    for(int i = 1; i < lines.length; i++){
      if(lines[i].startsWith("System ")){
        system(list, lines[i], i);
      } else if(lines[i].startsWith("Actor ")){
        actor(list, lines[i], i);
      } else if(lines[i].startsWith("UseCase ")){
        useCase(list, lines[i], i);
      } else if(lines[i].contains("=")){
        assignment(list, lines[i], i);
      } else if(lines[i].contains("->")){
        arrow(list, lines[i], i);
      } else if(lines[i].contains(" implements ")){
        implementation(list, lines[i], i);
      } else if(lines[i].contains(" extends ")){
        extension(list, lines[i], i);
      } else if(lines[i].contains(" includes ")){
        inclusion(list, lines[i], i);
      } else if(lines[i].contains(" add ")){
        add(list, lines[i], i);
      }
    }
    return list;
  }

  void add(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" add ");
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
      if(list[a] is System && list[b] is UseCase){
        System sys = list[a];
        UseCase uc = list[b];
        sys.useCases.add(uc);
      } else {
        print("ERROR: invalid variable types\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void inclusion(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" includes ");
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
      if(list[a] is UseCase && list[b] is UseCase){
        UseCase useCase1 = list[a];
        UseCase useCase2 = list[b];
        useCase1.inclusions.add(useCase2);
      } else {
        print("ERROR: invalid variable types\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void extension(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" extends ");
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
      if(list[a] is UseCase && list[b] is UseCase){
        UseCase useCase1 = list[a];
        UseCase useCase2 = list[b];
        useCase1.extensions.add(useCase2);
      } else {
        print("ERROR: invalid variable types\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void implementation(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" implements ");
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
      if(list[a] is Actor && list[b] is Actor){
        Actor actor1 = list[a];
        Actor actor2 = list[b];
        actor1.implementations.add(actor2);
      } else {
        print("ERROR: invalid variable types\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void arrow(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split("->");
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
      if(list[a] is Actor && list[b] is UseCase){
        Actor actor = list[a];
        UseCase useCase = list[b];
        actor.connections.add(useCase);
      } else {
        print("ERROR: invalid variable types\nline: $lineNumber");
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void assignment(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split("=");
    if(parts[0].contains(".")){
      List<String> leftParts = parts[0].split(".");
      for(int i = 0; i < list.length; i++){
        if(leftParts[0] == list[i].name){
          if(list[i] is System){
            if(leftParts[1] == "text" && parts[1][0] == "\"" 
                && parts[1][parts[1].length - 1] == "\""){
              System sys = list[i];
              sys.text = parts[1].replaceAll("\"", "");
            } else {
              print("ERROR: assignment error\nline: $lineNumber");
            }
          } else if(list[i] is Actor){
            if(leftParts[1] == "text" && parts[1][0] == "\"" 
                && parts[1][parts[1].length - 1] == "\""){
              Actor a = list[i];
              a.text = parts[1].replaceAll("\"", "");
            } else {
              print("ERROR: assignment error\nline: $lineNumber");
            }
          } else if(list[i] is UseCase){
            if(leftParts[1] == "text" && parts[1][0] == "\"" 
                && parts[1][parts[1].length - 1] == "\""){
              UseCase u = list[i];
              u.text = parts[1].replaceAll("\"", "");
            } else {
              print("ERROR: assignment error\nline: $lineNumber");
            }
          }
          break;
        }
      }
    } else {
      print("ERROR: invalid variable\nline: $lineNumber");
    }
  }

  void system(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" ");
    if(parts.length == 2 && !line.contains(".")){
      for(int i = 0; i < list.length; i++){
        if(parts[1] == list[i].name){
          print("ERROR: variable name already exists\nline: $lineNumber");
          return;
        }
      }
      System sys = new System();
      sys.name = parts[1];
      list.add(sys);
    } else {
      print("ERROR: invalid variable name\nline: $lineNumber");
    }
  }
  
  void actor(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" ");
    if(parts.length == 2 && !line.contains(".")){
      for(int i = 0; i < list.length; i++){
        if(parts[1] == list[i].name){
          print("ERROR: variable name already exists\nline: $lineNumber");
          return;
        }
      }
      Actor a = new Actor();
      a.name = parts[1];
      list.add(a);
    } else {
      print("ERROR: invalid variable name\nline: $lineNumber");
    }
  }

  void useCase(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" ");
    if(parts.length == 2 && !line.contains(".")){
      for(int i = 0; i < list.length; i++){
        if(parts[1] == list[i].name){
          print("ERROR: variable name already exists\nline: $lineNumber");
          return;
        }
      }
      UseCase u = new UseCase();
      u.name = parts[1];
      list.add(u);
    } else {
      print("ERROR: invalid variable name\nline: $lineNumber");
    }
  }
}