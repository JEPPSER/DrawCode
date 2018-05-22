import 'DiagramObject.dart';
import 'Square.dart';
import 'dart:html';

class Renderer {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Square){
        Square s = objects[i];
        g.strokeRect(i*100, i*100, s.width, s.height);
        g.fillText(s.text, i*100 + 50, i*100 + 25);
      }
    }
  }
}