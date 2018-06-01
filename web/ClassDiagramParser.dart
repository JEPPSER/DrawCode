import 'DiagramObject.dart';

class ClassDiagramParser {

  List<DiagramObject> parse(String string){
    List<DiagramObject> list = new List<DiagramObject>();
    List<String> lines = string.split("\n");
    for(int i = 1; i < lines.length; i++){
      if(lines[i].startsWith("Class ")){

      } else if(lines[i].startsWith("Enum ")){

      } else if(lines[i].startsWith("Interface ")){

      } else if(lines[i].contains(" add ")){

      } else if(lines[i].contains("- ->")){

      } else if(lines[i].contains("-|>")){

      } else if(lines[i].contains("- -|>")){

      } else if(lines[i].contains(")-(")){

      } else if(lines[i].contains(")->(")){

      } else if(lines[i].contains(")<>-(")){

      } else if(lines[i].contains(")<#>-(")){

      }
    }
    return list;
  }
}