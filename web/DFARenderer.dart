import 'dart:html';
import 'dart:math';
import 'DiagramObject.dart';
import 'State.dart';
import 'Arrow.dart';

class DFARenderer {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale =  2.0 - (objects.length / 10);
    if(scale < 1.4){
      scale = 1.4;
    }

    g.font = (12 * scale).toString() + "px Arial";

    // Draw objects
    for(int i = 0; i < objects.length; i++){
      State s = objects[i];
      drawArrows(g, s);
      drawState(g, s);
      g.fillText(s.name, s.x + s.width / 2, s.y + s.height / 2);
    }
  }

  void drawState(CanvasRenderingContext2D g, State state){
    g.beginPath();
    g.arc(state.x + state.width / 2, state.y + state.height / 2, state.width / 2, 0, 2*PI);
    g.stroke();
    if(state.type == StateType.END){
      g.beginPath();
      g.arc(state.x + state.width / 2, state.y + state.height / 2, state.width / 2.5, 0, 2*PI);
      g.stroke();
    }
  }

  void drawArrows(CanvasRenderingContext2D g, State state){
    g.beginPath();
    for(int i = 0; i < state.connections.length; i++){
      Arrow a = state.connections[i];
      g.moveTo(a.points[0].x, a.points[0].y);
      for(int j = 1; j < a.points.length; j++){
        g.lineTo(a.points[j].x, a.points[j].y);
      }
    }
    g.stroke();
  }
}