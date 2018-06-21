import 'DiagramObject.dart';
import 'DFARenderer.dart';
import 'State.dart';
import 'Arrow.dart';
import 'dart:html';
import 'dart:math';

class DFA {

  Random rand = new Random();
  List<State> doneObjects = new List<State>();
  int length = 200;
  List<DiagramObject> objects;

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.2){
      scale = 1.2;
    }
    g.font = (12 * scale).toString() + "px Arial";

    this.objects = objects;

    // Set x and y for all objects.
    if(objects.length > 1){
      objects[0].x = 400;
      objects[0].y = 400;
      objects[1].x = 400 + length;
      objects[1].y = 400;
    }
    doneObjects.add(objects[0]);
    doneObjects.add(objects[1]);
    for(int i = 0; i < objects.length; i++){
      State s = objects[i];
      placeConnections(s);
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

    List<Arrow> doneArrows = new List<Arrow>();

    // Bend arrows that go back and forth.
    for(int i = 0; i < objects.length; i++){
      State s = objects[i];
      for(int j = 0; j < s.connections.length; j++){
        State other = s.connections[j].to;
        if(!doneArrows.contains(s.connections[j]) && s != other){
          for(int k = 0; k < other.connections.length; k++){
            if(other.connections[k].to == s && !doneArrows.contains(other.connections[k])){
              Point a = new Point(s.x + s.width / 2, s.y + s.height / 2);
              Point b = new Point(other.x + other.width / 2, other.y + other.height / 2);
              Point middle = getMiddle(a, b);
              double angle = PI - (PI / 2 - atan2(b.y  - a.y, b.x - a.x));
              double x = 20 * cos(angle);
              double y = 20 * sin(angle);
              Point temp = other.connections[k].points[1];
              other.connections[k].points.add(temp);
              other.connections[k].points[1] = new Point(middle.x + x, middle.y + y);
              setEdgePoints(other.connections[k]);
              doneArrows.add(other.connections[k]);
              temp = s.connections[j].points[1];
              s.connections[j].points.add(temp);
              s.connections[j].points[1] = new Point(middle.x - x, middle.y - y);
              setEdgePoints(s.connections[j]);
              doneArrows.add(s.connections[j]);
            }
          }
        }   
      }
    }

    DFARenderer renderer = new DFARenderer();
    renderer.render(g, objects);
  }

  void placeConnections(State s){
    for(int i = 0; i < s.connections.length; i++){
      Arrow a = s.connections[i];
      if(!doneObjects.contains(a.to)){
        bool done = false;
        for(int j = 0; !done && j < 100; j++){
          double angle = rand.nextDouble() * 2 * PI;
          int x = (a.from.x + cos(angle) * length).floor();
          int y = (a.from.y + sin(angle) * length).floor();
          if(x < 0 || y < 0 || x > 1800 || y > 1000 || isOverlapping(x, y)){
            done = false;
          } else {
            done = true;
            a.to.x = x;
            a.to.y = y;
            doneObjects.add(a.to);
            placeConnections(a.to);
          }
        }
      }
    }
  }

  bool isOverlapping(int x, int y){
    bool result = false;
    for(int i = 0; i < objects.length; i++){
      if(objects[i].x != null && objects[i].y != null){
        Point one = new Point(x, y);
        Point two = new Point(objects[i].x, objects[i].y);
        if(one.distanceTo(two) < 100){
          result = true;
          break;
        }
      }
    }
    return result;
  }

  Point getMiddle(Point a, Point b){
    int x = a.x + (b.x - a.x) / 2;
    int y = a.y + (b.y - a.y) / 2;
    return new Point(x, y);
  }

  void setEdgePoints(Arrow a){
    if(a.from != a.to){
      Point from = new Point(a.from.x + a.from.width / 2, a.from.y + a.from.height / 2);
      double angle = getAngle(from, a.points[1]);
      double x = (a.from.width / 2) * cos(angle);
      double y = (a.from.width / 2) * sin(angle);
      a.points[0] = new Point(a.from.x + a.from.width / 2 + x, a.from.y + a.from.height / 2 + y);
      Point to = new Point(a.to.x + a.to.width / 2, a.to.y + a.to.height / 2);
      angle = getAngle(to, a.points[1]);
      x = (a.to.width / 2) * cos(angle);
      y = (a.to.width / 2) * sin(angle);
      a.points[2] = new Point(a.to.x + a.to.width / 2 + x, a.to.y + a.to.height / 2 + y);
    }  
  }

  double getAngle(Point a, Point b){
    return atan2(b.y  - a.y, b.x - a.x);
  }
}