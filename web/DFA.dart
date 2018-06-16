import 'DiagramObject.dart';
import 'DFARenderer.dart';
import 'State.dart';
import 'Arrow.dart';
import 'dart:html';
import 'dart:math';

class DFA {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.2){
      scale = 1.2;
    }
    g.font = (12 * scale).toString() + "px Arial";

    Random rand = new Random();

    // Set x and y for all objects.
    for(int i = 0; i < objects.length; i++){
      State s = objects[i];
      s.x = rand.nextInt(700);
      s.y = rand.nextInt(500);
    }

    // Set points for arrows
    for(int i = 0; i < objects.length; i++){
      State s = objects[i];
      for(int j = 0; j < s.connections.length; j++){
        Arrow a = s.connections[j];
        if(a.points.length < 2){
          if(a.from == a.to){
            double ang = PI / 3;
            double x = s.width / 2 * cos(ang);
            double y = s.width / 2 * sin(ang);
            a.points.add(new Point(s.x + s.width / 2 + x, s.y + s.height / 2 + y));
            a.points.add(new Point(s.x + s.width / 2, s.y + s.height + scale * 25));
            a.points.add(new Point(s.x + s.width / 2 - x, s.y + s.height / 2 + y));
          } else {
            double angle = atan2(a.to.y - a.from.y, a.to.x - a.from.x);
            double x = s.width / 2 * cos(angle);
            double y = s.width / 2 * sin(angle);
            a.points.add(new Point(a.from.x + a.from.width / 2 + x, a.from.y + a.from.height / 2 + y));
            a.points.add(new Point(a.to.x + a.to.width / 2 - x, a.to.y + a.to.height / 2 - y));
          }
        }
      }
    }

    DFARenderer renderer = new DFARenderer();
    renderer.render(g, objects);
  }
}