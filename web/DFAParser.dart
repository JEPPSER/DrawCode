import 'DiagramObject.dart';
import 'State.dart';
import 'Arrow.dart';

class DFAParser {

  List<DiagramObject> parse(String string){
    List<DiagramObject> list = new List<DiagramObject>();
    List<String> lines = string.split("\n");
    for(int i = 1; i < lines.length; i++){
      if(lines[i].startsWith("State ")){
        state(list, lines[i],  i, StateType.NORMAL);
      } else if(lines[i].startsWith("->State ")){
        state(list, lines[i],  i, StateType.START);
      } else if(lines[i].startsWith("(State) ")){
        state(list, lines[i],  i, StateType.END);
      } else if(lines[i].contains("->") && lines[i].split(":").length == 2 && !lines[i].startsWith("->")){
        arrow(list, lines[i], i);
      }
    }
    return list;
  }

  void state(List<DiagramObject> list, String line, int lineNumber, StateType type){
    List<String> parts = line.split(" ");
    if(parts.length == 2 && !line.contains(".")){
      for(int i = 0; i < list.length; i++){
        if(parts[1] == list[i].name){
          print("ERROR: variable name already exists\nline: $lineNumber");
          return;
        }
      }
      State s = new State();
      s.name = parts[1];
      s.type = type;
      list.add(s);
    } else {
      print("ERROR: invalid variable name\nline: $lineNumber");
    }
  }

  void arrow(List<DiagramObject> list, String line, int lineNumber){
    String temp = line.split(": ")[0];
    List<String> parts = temp.split("->");
    int a = -1;
    int b = -1;
    for(int i = 0; i < list.length; i++){
      if(list[i].name == parts[0]){
        a = i;
      }
      if(list[i].name == parts[1]){
        b = i;
      }
    }
    if(a != -1 && b != -1){
      State s = list[a];
      Arrow arrow = new Arrow();
      arrow.from = s;
      arrow.to = list[b];
      String text = line.split(": ")[1];
      arrow.text = text;
      s.connections.add(arrow);
    } else {
      print("ERROR: invalid variable names\nline: $lineNumber");
    }
  }
}