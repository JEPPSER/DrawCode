import 'DiagramObject.dart';
import 'Square.dart';

class FlowchartParser {

  List<DiagramObject> parse(String string){
    List<DiagramObject> list = new List<DiagramObject>();
    List<String> lines = string.split("\n");
    for(int i = 1; i < lines.length; i++){
      if(lines[i].startsWith("Square ")){
        square(list, lines[i], i);
      } else if(lines[i].contains("=") && lines[i].split("=").length == 2){
        assignment(list, lines[i], i);
      } else if(lines[i].contains("->") && lines[i].split("->").length == 2){
        arrow(list, lines[i], i);
      }
    }
    return list;
  }

  void arrow(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.replaceAll(" ", "").split("->");
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
      }
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }

  void assignment(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.replaceAll(" ", "").split("=");
    if(parts[0].contains(".")){
      List<String> leftParts = parts[0].split(".");
      for(int i = 0; i < list.length; i++){
        if(leftParts[0] == list[i].name){
          if(list[i] is Square){
            assignSquare(list, parts, i, lineNumber);
          }
          break;
        }
      }
    } else {
      print("ERROR: invalid variable\nline: $lineNumber");
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

  void square(List<DiagramObject> list, String line, int lineNumber){
    List<String> parts = line.split(" ");
    if(parts.length == 2 && !line.contains(".")){
      Square s = new Square();
      s.name = parts[1];
      list.add(s);
    } else {
      print("ERROR: invalid variable name\nline: $lineNumber");
    }
  }
}