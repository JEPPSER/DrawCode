import 'dart:html';
import 'dart:math';
import 'DiagramObject.dart';
import 'ClassRenderer.dart';
import 'Class.dart';
import 'Arrow.dart';

class ClassDiagram {

  Random rand = new Random();
  List<Class> doneObjects = new List<Class>();
  int length = 200;
  List<DiagramObject> objects;

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    this.objects = objects;

    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.2){
      scale = 1.2;
    }
    g.font = (8 * scale).toString() + "px Lucida Console";

    // Set size of all objects.
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Class){
        Class s = objects[i];
        int memberHeight = (s.members.length * 10 * scale + scale * 2).round();
        int width = 0;
        for(int j = 0; j < s.members.length; j++){
          if(s.members[j].length > width){
              width = s.members[j].length;
          }
        }
        if(s.name.length > width){
          width = s.name.length;
        }
        width *= (5 * scale).round();
        if(width < scale * 70){
          width = (scale * 70).round();
        }
        s.width = width;
        if(s.type == ClassType.CLASS){
          s.height = (scale * 10 + memberHeight).round();
        } else if(s.type == ClassType.ENUM){
          s.height = (scale * 10 * 2 + memberHeight).round();
        } else if(s.type == ClassType.INTERFACE){
          s.height = (scale * 10 * 2 + memberHeight).round();
        }
      }
    }

    // Set x and y for all objects.
    if(objects.length > 0){
      objects[0].x = 400;
      objects[0].y = 400;
    }
    doneObjects.add(objects[0]);
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Class){
        Class s = objects[i];
        placeConnections(s);
      }
    }

    ClassRenderer renderer = new ClassRenderer();
    renderer.render(g, objects);
  }

  List<Arrow> getConnections(Class s){
    List<Arrow> list = new List<Arrow>();
    list.addAll(s.aggregations);
    list.addAll(s.associations);
    list.addAll(s.compositions);
    list.addAll(s.dAssociations);
    list.addAll(s.dependencies);
    list.addAll(s.inheritances);
    list.addAll(s.realizations);
    return list;
  }

  void placeConnections(Class s){
    List<Arrow> connections = getConnections(s);
    for(int i = 0; i < connections.length; i++){
      Arrow a = connections[i];
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
}