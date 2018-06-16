import 'DiagramObject.dart';
import 'DFARenderer.dart';
import 'dart:html';
import 'dart:math';

class DFA {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.2){
      scale = 1.2;
    }
    g.font = (8 * scale).toString() + "px Arial";

    Random rand = new Random();

    // Set x and y for all objects.
    for(int i = 0; i < objects.length; i++){
      int x = rand.nextInt(700);
      int y = rand.nextInt(500);
      objects[i].x = x;
      objects[i].y = y;
    }

    DFARenderer renderer = new DFARenderer();
    renderer.render(g, objects);
  }
}