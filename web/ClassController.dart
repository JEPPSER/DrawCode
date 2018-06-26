import 'dart:html';
import 'dart:async';
import 'dart:math';
import 'ClassRenderer.dart';
import 'DiagramObject.dart';
import 'Arrow.dart';
import 'Class.dart';

class ClassController {

  CanvasElement canvas;
  CanvasRenderingContext2D g;
  List<DiagramObject> objects;
  bool isDown = false;
  DiagramObject currentObject;
  Arrow currentArrow;
  int arrowPointIndex = 0;
  bool isOnPoint = false;
  List<StreamSubscription> subs;
  ClassRenderer renderer;
  Point startPoint;

  ClassController(CanvasElement canvas, CanvasRenderingContext2D g, List<DiagramObject> objects){
    this.canvas = canvas;
    this.g = g;
    this.objects = objects;
    subs = new List<StreamSubscription>();
    renderer = new ClassRenderer();
  }

  void listen(){
    StreamSubscription s1 = canvas.onMouseDown.listen((MouseEvent me) {
      Point mousePos = getMousePosition(me);
      if(currentArrow != null && !isDown){ // if mouse is over arrow
        if(!isOnPoint && me.button == 0){
          addAt(currentArrow.points, mousePos, arrowPointIndex);
        } else if(isOnPoint && me.button == 2){
          currentArrow.points.removeAt(arrowPointIndex);
          g.clearRect(0, 0, canvas.width, canvas.height);
          renderer.render(g, objects);
        }
      } else {
        for(int i = 0; i < objects.length; i++){
          if(objects[i] is Class){
            Rectangle r = new Rectangle(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
            if(r.containsPoint(mousePos)){
              currentObject = objects[i];
              startPoint = mousePos;
            }
          }  
        }
      }
      isDown = true;
    });

    StreamSubscription s2 = canvas.onMouseMove.listen((MouseEvent me) {
      Point mousePos = getMousePosition(me);
      if(!isDown){ // Just hovering
        g.clearRect(0, 0, canvas.width, canvas.height);
        renderer.render(g, objects);
        outerloop:
        for(int i = 0; i < objects.length; i++){
          if(objects[i] is Class){
            Class s = objects[i];
            List<Arrow> connections = getConnections(s);
            for(int j = 0; j < connections.length; j++){
              Arrow arrow = connections[j];
              for(int k = 0; k < arrow.points.length; k++){
                if(mousePos.distanceTo(arrow.points[k]) < 15){
                  drawRedCircle(g, arrow.points[k].x, arrow.points[k].y);
                  currentArrow = arrow;
                  arrowPointIndex = k;
                  isOnPoint = true;
                  break outerloop;
                } else if(k > 0){
                  isOnPoint = false;
                  Point a = arrow.points[k - 1];
                  Point b = arrow.points[k];
                  double v = PI / 2 - (getAngle(a, b) - getAngle(mousePos, b));
                  double length = cos(v) * mousePos.distanceTo(b);
                  int margin = 10;
                  if(length < margin && length > -margin && isWithinPoints(a, b, mousePos, margin)){
                    drawGreenCircle(g, mousePos.x, mousePos.y);
                    currentArrow = arrow;
                    arrowPointIndex = k;
                    break outerloop;
                  } else {
                    currentArrow = null;
                    arrowPointIndex = 0;
                  }
                }
              }
            }
          }
        }
      } else if(isDown && currentObject != null){ // Holding on an object
        currentObject.x += mousePos.x - startPoint.x;
        currentObject.y += mousePos.y - startPoint.y;
        for(int i = 0; i < objects.length; i++){
          if(objects[i] is Class){
            Class s = objects[i];
            List<Arrow> connections = getConnections(s);
            if(s == currentObject){
              for(int j = 0; j < connections.length; j++){
                int x = connections[j].points[0].x + mousePos.x - startPoint.x;
                int y = connections[j].points[0].y + mousePos.y - startPoint.y;
                connections[j].points[0] = new Point(x, y);
              }
            } else {
              for(int j = 0; j < connections.length; j++){
                if(connections[j].to == currentObject){
                  int x = connections[j].points[connections[j].points.length - 1].x + mousePos.x - startPoint.x;
                  int y = connections[j].points[connections[j].points.length - 1].y + mousePos.y - startPoint.y;
                  connections[j].points[connections[j].points.length - 1] = new Point(x, y);
                }
              }
            }
          }
        }
        g.clearRect(0, 0, canvas.width, canvas.height);
        renderer.render(g, objects);
        startPoint = mousePos;
      } else if(isDown && currentArrow != null){ // Holding on an arrow
        if(me.button == 0){
          currentArrow.points[arrowPointIndex] = getMousePosition(me);
          g.clearRect(0, 0, canvas.width, canvas.height);
          renderer.render(g, objects);
        }
      }
    });

    StreamSubscription s3 = canvas.onMouseUp.listen((MouseEvent me) {
      currentObject = null;
      isDown = false;
    });

    subs.add(s1);
    subs.add(s2);
    subs.add(s3);
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

  Point getPoint(double angle, double length, Point p){
    if(angle < 0){
      angle += 2*PI;
    }
    double v = PI / 2 - angle;
    double x = length * cos(v);
    double y = sqrt(length*length - x*x);
    return new Point(p.x + x, p.y + y);  
  }

  drawGreenCircle(CanvasRenderingContext2D g, int x, int y){
    g.beginPath();
    g.setFillColorRgb(0, 255, 0, 0.5);
    g.arc(x, y, 10, 0, PI * 2);
    g.fill();
    g.closePath();
    g.setFillColorRgb(0, 0, 0);
  }

  drawRedCircle(CanvasRenderingContext2D g, int x, int y){
    g.beginPath();
    g.setFillColorRgb(255, 0, 0, 0.5);
    g.arc(x, y, 15, 0, PI * 2);
    g.fill();
    g.closePath();
    g.setFillColorRgb(0, 0, 0);
  }

  Point getMousePosition(MouseEvent me){
    Rectangle rect = canvas.getBoundingClientRect();
    Point mousePos = new Point(me.client.x - rect.left, me.client.y - rect.top);
    return mousePos;
  }
  
  List<StreamSubscription> getSubscriptions(){
    return subs;
  }

  double getAngle(Point a, Point b){
    return atan2(b.y  - a.y, b.x - a.x);
  }

  bool isWithinPoints(Point a, Point b, Point mousePos, int margin){
    Rectangle rect;
    if(a.x >= b.x && a.y >= b.y){
      rect = new Rectangle(b.x - margin, b.y - margin, a.x - b.x + margin * 2, a.y - b.y + margin * 2);
    } else if(a.x >= b.x && a.y <= b.y){
      rect = new Rectangle(b.x - margin, a.y - margin, a.x - b.x + margin * 2, b.y - a.y + margin * 2);
    } else if(a.x <= b.x && a.y <= b.y){
      rect = new Rectangle(a.x - margin, a.y - margin, b.x - a.x + margin * 2, b.y - a.y + margin * 2);
    } else if(a.x <= b.x && a.y >= b.y){
      rect = new Rectangle(a.x - margin, b.y - margin, b.x - a.x + margin * 2, a.y - b.y + margin * 2);
    }
    return rect.containsPoint(mousePos);
  }

  void addAt(List<Point> points, Point p, int index){
    points.add(p);
    for(int i = points.length - 1; i > index; i--){
      points[i] = points[i - 1];
    }
    points[index] = p;
  }
}