import 'dart:html';
import 'DiagramObject.dart';
import 'Class.dart';

class ClassRenderer {

  double scale;

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    scale = 2.0 - (objects.length / 10);
    if(scale < 1.2){
      scale = 1.2;
    }
    g.font = (8 * scale).toString() + "px Arial";

    g.beginPath();

    // Draw objects
    for(int i = 0; i < objects.length; i++){
      Class s = objects[i];
      if(s.type == ClassType.CLASS){
        drawClass(g, s);
      } else if(s.type == ClassType.ENUM){
        drawEnum(g, s);
      } else if(s.type == ClassType.INTERFACE){
        drawInterface(g, s);
      }
    }

    g.stroke();
  }

  void drawEnum(CanvasRenderingContext2D g, Class s){
    g.strokeRect(s.x, s.y, s.width, s.height);
    g.moveTo(s.x, s.y + scale * 10 * 2);
    g.lineTo(s.x + s.width, s.y + scale * 10 * 2);
    int textX1 = ((s.x + s.width / 2) - 15 * scale * 2.1).floor();
    int textX2 = ((s.x + s.width / 2) - s.name.length * scale * 2.4).floor();
    g.fillText("<<enumeration>>", textX1, s.y + scale * 8);
    g.font = "bold " + (8 * scale).toString() + "px Arial";
    g.fillText(s.name, textX2, s.y + scale * 8 * 2);
    g.font = (8 * scale).toString() + "px Arial";
    for(int i = 0; i < s.members.length; i++){
      double x = s.x + scale * 2;
      double y = s.y + scale * 10 * (i + 3) - scale * 2;
      g.fillText(s.members[i], x, y);
    }
  }

  void drawInterface(CanvasRenderingContext2D g, Class s){
    g.strokeRect(s.x, s.y, s.width, s.height);
    g.moveTo(s.x, s.y + scale * 10 * 2);
    g.lineTo(s.x + s.width, s.y + scale * 10 * 2);
    int textX1 = ((s.x + s.width / 2) - 13 * scale * 1.9).floor();
    int textX2 = ((s.x + s.width / 2) - s.name.length * scale * 2.4).floor();
    g.fillText("<<interface>>", textX1, s.y + scale * 8);
    g.font = "bold " + (8 * scale).toString() + "px Arial";
    g.fillText(s.name, textX2, s.y + scale * 8 * 2);
    g.font = (8 * scale).toString() + "px Arial";
    List<String> field = new List<String>();
    List<String> methods = new List<String>();
    for(int j = 0; j < s.members.length; j++){
      if(s.members[j].contains("(") && s.members[j].contains(")")){
        methods.add(s.members[j]);
      } else {
        field.add(s.members[j]);
      }
    }
    int j;
    for(j = 0; j < field.length; j++){
      double x = s.x + scale * 2;
      double y = s.y + scale * 10 * (j + 3) - scale * 2;
      g.fillText(field[j], x, y);
    }
    double nwY = s.y + scale * 10 * (j + 2);
    g.moveTo(s.x, nwY);
    g.lineTo(s.x + s.width, nwY);
    for(j = 0; j < methods.length; j++){
      double x = s.x + scale * 2;
      double y = nwY + scale * 10 * (j + 1) - scale * 2;
      g.fillText(methods[j], x, y);
    }
  }

  void drawClass(CanvasRenderingContext2D g, Class s){
    g.strokeRect(s.x, s.y, s.width, s.height);
    g.moveTo(s.x, s.y + scale * 10);
    g.lineTo(s.x + s.width, s.y + scale * 10);
    List<String> field = new List<String>();
    List<String> methods = new List<String>();
    for(int j = 0; j < s.members.length; j++){
      if(s.members[j].contains("(") && s.members[j].contains(")")){
        methods.add(s.members[j]);
      } else {
        field.add(s.members[j]);
      }
    }
    g.font = "bold " + (8 * scale).toString() + "px Arial";
    int textX = ((s.x + s.width / 2) - s.name.length * scale * 2.4).floor();
    g.fillText(s.name, textX, s.y + scale * 8);
    g.font = (8 * scale).toString() + "px Arial";
    int j;
    for(j = 0; j < field.length; j++){
      double x = s.x + scale * 2;
      double y = s.y + scale * 10 * (j + 2) - scale * 2;
      g.fillText(field[j], x, y);
    }
    double nwY = s.y + scale * 10 * (j + 1);
    g.moveTo(s.x, nwY);
    g.lineTo(s.x + s.width, nwY);
    for(j = 0; j < methods.length; j++){
      double x = s.x + scale * 2;
      double y = nwY + scale * 10 * (j + 1) - scale * 2;
      g.fillText(methods[j], x, y);
    }
  }
}