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

      } else if(isDown && currentObject != null){ // Holding on an object
        currentObject.x += mousePos.x - startPoint.x;
        currentObject.y += mousePos.y - startPoint.y;
        g.clearRect(0, 0, canvas.width, canvas.height);
        renderer.render(g, objects);
        startPoint = mousePos;
      } else if(isDown && currentArrow != null){ // Holding on an arrow

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