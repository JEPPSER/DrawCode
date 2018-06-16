import 'dart:html';
import 'DiagramObject.dart';
import 'State.dart';

class DFARenderer {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale =  2.0 - (objects.length / 10);
    if(scale < 1.4){
      scale = 1.4;
    }

    g.font = (8 * scale).toString() + "px Arial";

    for(int i = 0; i < objects.length; i++){
      State s = objects[i];
      g.strokeRect(s.x, s.y, s.width, s.height);
      g.fillText(s.name, s.x + s.width / 2, s.y + s.height / 2);
    }
  }
}