import 'DiagramObject.dart';
import 'FlowchartRenderer.dart';
import 'Square.dart';
import 'If.dart';
import 'Arrow.dart';
import 'dart:html';
import 'dart:async';
import 'dart:math';

class FlowchartController {

  CanvasElement canvas;
  CanvasRenderingContext2D g;
  List<DiagramObject> objects;
  bool isDown = false;
  DiagramObject currentObject;
  Arrow currentArrow;
  If currentIf;
  String currentText = "";
  int arrowPointIndex = 0;
  bool isOnPoint = false;
  List<StreamSubscription> subs;
  FlowchartRenderer renderer;

  Point startPoint;

  FlowchartController(CanvasElement canvas, CanvasRenderingContext2D g, List<DiagramObject> objects){
    this.canvas = canvas;
    this.g = g;
    this.objects = objects;
    subs = new List<StreamSubscription>();
    renderer = new FlowchartRenderer();
  }

  void listen(){
    StreamSubscription s1 = canvas.onMouseDown.listen((MouseEvent me) {
      Point mousePos = getMousePosition(me);
      if(currentArrow != null && !isDown){
        if(!isOnPoint && me.button == 0){
          addAt(currentArrow.points, mousePos, arrowPointIndex);
        } else if(isOnPoint && me.button == 2){
          currentArrow.points.removeAt(arrowPointIndex);
          g.clearRect(0, 0, canvas.width, canvas.height);
          renderer.render(g, objects);
        }
      } else {
        for(int i = 0; i < objects.length; i++){
          Rectangle r = new Rectangle(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
          if(r.containsPoint(mousePos)){
            currentObject = objects[i];
            startPoint = mousePos;
          }
        }
      }
      isDown = true;
    });

    StreamSubscription s2 = canvas.onMouseMove.listen((MouseEvent me){
      Point mousePos = getMousePosition(me);
      if(!isDown) { // Just hovering
        g.clearRect(0, 0, canvas.width, canvas.height);
        renderer.render(g, objects);
        outerloop:
        for(int i = 0; i < objects.length; i++){
          if(objects[i] is Square){
            Square s = objects[i];
            for(int j = 0; j < s.connections.length; j++){
              Arrow arrow = s.connections[j];
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
          } else if(objects[i] is If){
            If s = objects[i];
            List<Arrow> connections = new List<Arrow>();
            if(s.yes != null){
              connections.add(s.yes);
            }
            if(s.no != null){
              connections.add(s.no);
            }
            if(s.yesPoint != null && mousePos.distanceTo(s.yesPoint) < 10){
              drawOrangeCircle(g, s.yesPoint.x, s.yesPoint.y);
              currentIf = s;
              currentText = "yes";
              break outerloop;
            } else if(s.noPoint != null && mousePos.distanceTo(s.noPoint) < 10){
              drawOrangeCircle(g, s.noPoint.x, s.noPoint.y);
              currentIf = s;
              currentText = "no";
              break outerloop;
            } else {
              currentIf = null;
              currentText = "";
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
        }
      } else if(isDown && currentIf != null){ // Holding on yes or no text in an If object.
        if(currentText == "yes"){
          currentIf.yesPoint = mousePos;
        } else if(currentText == "no"){
          currentIf.noPoint = mousePos;
        }
        g.clearRect(0, 0, canvas.width, canvas.height);
        renderer.render(g, objects);
      } else if(isDown && currentObject != null){ // Holding on an object
        currentObject.x += mousePos.x - startPoint.x;
        currentObject.y += mousePos.y - startPoint.y;
        if(currentObject is If){
          If s = currentObject;
          s.noPoint = new Point(s.noPoint.x + mousePos.x - startPoint.x, s.noPoint.y + mousePos.y - startPoint.y);
          s.yesPoint = new Point(s.yesPoint.x + mousePos.x - startPoint.x, s.yesPoint.y + mousePos.y - startPoint.y);
        }
        for(int j = 0; j < objects.length; j++){
          if(objects[j] is Square){
            Square s = objects[j];
            if(s == currentObject){
              for(int i = 0; i < s.connections.length; i++){
                int x = s.connections[i].points[0].x + mousePos.x - startPoint.x;
                int y = s.connections[i].points[0].y + mousePos.y - startPoint.y;
                s.connections[i].points[0] = new Point(x, y);
              }
            } else {
              for(int i = 0; i < s.connections.length; i++){
                if(s.connections[i].to == currentObject){
                  int x = s.connections[i].points[s.connections[i].points.length - 1].x + mousePos.x - startPoint.x;
                  int y = s.connections[i].points[s.connections[i].points.length - 1].y + mousePos.y - startPoint.y;
                  s.connections[i].points[s.connections[i].points.length - 1] = new Point(x, y);
                }
              }
            }
          } else if(objects[j] is If){
            If s = objects[j];
            List<Arrow> connections = new List<Arrow>();
            if(s.yes != null){
              connections.add(s.yes);
            }
            if(s.no != null){
              connections.add(s.no);
            }
            if(s == currentObject){
              for(int i = 0; i < connections.length; i++){
                int x = connections[i].points[0].x + mousePos.x - startPoint.x;
                int y = connections[i].points[0].y + mousePos.y - startPoint.y;
                connections[i].points[0] = new Point(x, y);
              }
            } else {
              for(int i = 0; i < connections.length; i++){
                if(connections[i].to == currentObject){
                  int x = connections[i].points[connections[i].points.length - 1].x + mousePos.x - startPoint.x;
                  int y = connections[i].points[connections[i].points.length - 1].y + mousePos.y - startPoint.y;
                  connections[i].points[connections[i].points.length - 1] = new Point(x, y);
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

    StreamSubscription s3 = canvas.onMouseUp.listen((MouseEvent me){
      currentObject = null;
      isDown = false;
    });

    subs.add(s1);
    subs.add(s2);
    subs.add(s3);
  }
  
  drawOrangeCircle(CanvasRenderingContext2D g, int x, int y){
    g.beginPath();
    g.setFillColorRgb(255, 100, 0, 0.5);
    g.arc(x, y, 10, 0, PI * 2);
    g.fill();
    g.closePath();
    g.setFillColorRgb(0, 0, 0);
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

  Point getPoint(double angle, double length, Point p){
    if(angle < 0){
      angle += 2*PI;
    }
    double v = PI / 2 - angle;
    double x = length * cos(v);
    double y = sqrt(length*length - x*x);
    return new Point(p.x + x, p.y + y);  
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