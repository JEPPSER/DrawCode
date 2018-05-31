import 'DiagramObject.dart';
import 'If.dart';
import 'Square.dart';
import 'Text.dart';

class FlowchartParser {

  List<DiagramObject> parse(String string){
    List<DiagramObject> list = new List<DiagramObject>();
    List<String> lines = string.split("\n");
    for(int i = 1; i < lines.length; i++){
      if(lines[i].startsWith("Step ")){
        square(list, lines[i], i, SquareType.STEP);
      } else if(lines[i].startsWith("Start ")){
        square(list, lines[i], i, SquareType.START);
      } else if(lines[i].startsWith("End ")){
        square(list, lines[i], i, SquareType.END);
      } else if(lines[i].startsWith("IOBox ")){
        square(list, lines[i], i, SquareType.IO_BOX);
      } else if(lines[i].startsWith("Document ")){
        square(list, lines[i], i, SquareType.DOCUMENT);
      } else if(lines[i].startsWith("If ")){
        ifbox(list, lines[i], i);
      } else if(lines[i].contains("=") && lines[i].split("=").length == 2){
        assignment(list, lines[i], i);
      } else if(lines[i].contains("->") && lines[i].split("->").length == 2){
        arrow(list, lines[i], i);
      }
    }
    return list;
  }

  void ifbox(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" ");
    if(parts.length == 2 && !line.contains(".")){
      for(int i = 0; i < list.length; i++){
        if(parts[1] == list[i].name){
          print("ERROR: variable name already exists\nline: $lineNumber");
          return;
        }
      }
      If ifs = new If();
      ifs.name = parts[1];
      list.add(ifs);
    } else {
      print("ERROR: invalid variable name\nline: $lineNumber");
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
      if(list[a] is Square){
        Square s = list[a];
        s.connections.add(list[b]);
      } else {
        print("ERROR: invalid variable type\nline: $lineNumber");
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
          if(list[i] is Square){
            assignSquare(list, parts, i, lineNumber);
          } else if(list[i] is If){
            assignIf(list, parts, i, lineNumber);
          } else if(list[i] is Text){
            assignText(list, parts, i, lineNumber);
          }
          break;
        }
      }
    } else {
      print("ERROR: invalid variable\nline: $lineNumber");
    }
  }

  void assignText(List<DiagramObject> list, List<String> parts, int index, int lineNumber){
    String property = parts[0].split(".")[1];
    if(property == "text"){
      if(parts[1][0] == "\"" && parts[1][parts[1].length - 1] == "\""){
        Text s = list[index];
        s.text = parts[1].replaceAll("\"", "");
      } else {
        print("ERROR: string must be between two \" symbols\nline: $lineNumber");
      }
    }
  }

  void assignIf(List<DiagramObject> list, List<String> parts, int index, int lineNumber){
    String property = parts[0].split(".")[1];
    if(property == "text"){
      if(parts[1][0] == "\"" && parts[1][parts[1].length - 1] == "\""){
        If i = list[index];
        i.text = parts[1].replaceAll("\"", "");
      } else {
        print("ERROR: string must be between two \" symbols\nline: $lineNumber");
      }
    } else if(property == "yes"){
      for(int i = 0; i < list.length; i++){
        if(list[i].name == parts[1]){
          If ifs = list[index];
          ifs.yes = list[i];
          break;
        }
      }
    } else if(property == "no"){
      for(int i = 0; i < list.length; i++){
        if(list[i].name == parts[1]){
          If ifs = list[index];
          ifs.no = list[i];
          break;
        }
      }
    }
  }

  void assignSquare(List<DiagramObject> list, List<String> parts, int index, int lineNumber){
    String property = parts[0].split(".")[1];
    if(property == "text"){
      if(parts[1][0] == "\"" && parts[1][parts[1].length - 1] == "\""){
        Square s = list[index];
        s.text = parts[1].replaceAll("\"", "");
      } else {
        print("ERROR: string must be between two \" symbols\nline: $lineNumber");
      }
    }
  }

  void square(List<DiagramObject> list, String line, int lineNumber, SquareType type){
    List<String> parts = line.split(" ");
    if(parts.length == 2 && !line.contains(".")){
      for(int i = 0; i < list.length; i++){
        if(parts[1] == list[i].name){
          print("ERROR: variable name already exists\nline: $lineNumber");
          return;
        }
      }
      Square s = new Square();
      s.name = parts[1];
      s.type = type;
      list.add(s);
    } else {
      print("ERROR: invalid variable name\nline: $lineNumber");
    }
  }
}