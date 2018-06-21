import 'DiagramObject.dart';
import 'DFARenderer.dart';
import 'State.dart';
import 'Arrow.dart';
import 'dart:html';
import 'dart:async';
import 'dart:math';

class DFAController {

  CanvasElement canvas;
  CanvasRenderingContext2D g;
  List<DiagramObject> objects;
  bool isDown = false;
  int buttonIndex = 0;
  DiagramObject currentObject;
  List<StreamSubscription> subs;
  DFARenderer renderer;
  Arrow currentArrow;
  int arrowPointIndex = 0;
  bool isOnPoint = false;

  Point startPoint;

  DFAController(CanvasElement canvas, CanvasRenderingContext2D g, List<DiagramObject> objects){
    this.canvas = canvas;
    this.g = g;
    this.objects = objects;
    subs = new List<StreamSubscription>();
    renderer = new DFARenderer();
  }

  void listen(){
    StreamSubscription s1 = canvas.onMouseDown.listen((MouseEvent me) {
      Point mousePos = getMousePosition(me);
      buttonIndex = me.button;
      if(currentArrow != null && !isDown){
        if(!isOnPoint && buttonIndex == 0){
          addAt(currentArrow.points, mousePos, arrowPointIndex);
        } else if(isOnPoint && buttonIndex == 2 && currentArrow.points.length > 2 && currentArrow.from != currentArrow.to){
          setTwoPoints(currentArrow);
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
      if(!isDown){ // Just hovering
        g.clearRect(0, 0, canvas.width, canvas.height);
        renderer.render(g, objects);
        outerloop:
        for(int i = 0; i < objects.length; i++){
          State s = objects[i];
          for(int j = 0; j < s.connections.length; j++){
            Arrow arrow = s.connections[j];
            for(int k = 0; k < arrow.points.length; k++){
              if(mousePos.distanceTo(arrow.points[k]) < 100 && k != 0 &&
                  k != arrow.points.length - 1 && arrow.from != arrow.to && !isLoopingArrow(arrow)){
                drawRedCircle(g, arrow.points[k].x, arrow.points[k].y);
                if(mousePos.distanceTo(arrow.points[k]) < 15){
                  currentArrow = arrow;
                  arrowPointIndex = k;
                  isOnPoint = true;
                  break outerloop;
                }
              } else if(k > 0 && arrow.points.length == 2){
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
              } else {
                isOnPoint = false;
                arrowPointIndex = 0;
                currentArrow = null;
              }
            }
          }
        }
      } else if(isDown && currentObject != null){ // Holding on an object
        currentObject.x += mousePos.x - startPoint.x;
        currentObject.y += mousePos.y - startPoint.y;

        for(int i = 0; i < objects.length; i++){
          State s = objects[i];
          if(s == currentObject){
            for(int j = 0; j < s.connections.length; j++){
              Arrow a = s.connections[j];
              if(a.points.length <= 2){
                setTwoPoints(a);
              } else {
                int x1 = a.points[0].x + mousePos.x - startPoint.x;
                int y1 = a.points[0].y + mousePos.y - startPoint.y;
                int x2 = a.points[1].x + (mousePos.x - startPoint.x) / 2;
                int y2 = a.points[1].y + (mousePos.y - startPoint.y) / 2;
                a.points[0] = new Point(x1, y1);
                if(a.from != a.to){
                  a.points[1] = new Point(x2, y2);
                  setEdgePoints(a);
                } else {
                  x2 = a.points[1].x + mousePos.x - startPoint.x;
                  y2 = a.points[1].y + mousePos.y - startPoint.y;
                  a.points[1] = new Point(x2, y2);
                }
              }
            }
          }
          for(int j = 0; j < s.connections.length; j++){
            Arrow a = s.connections[j];
            if(a.points.length <= 2){
              setTwoPoints(a);
            } else {
              if(a.to == currentObject && a.to != a.from){
                int x1 = a.points[2].x + mousePos.x - startPoint.x;
                int y1 = a.points[2].y + mousePos.y - startPoint.y;
                int x2 = a.points[1].x + (mousePos.x - startPoint.x) / 2;
                int y2 = a.points[1].y + (mousePos.y - startPoint.y) / 2;
                a.points[2] = new Point(x1, y1);
                a.points[1] = new Point(x2, y2);
              }
              if(a.from != a.to){
                setEdgePoints(a);
              } else if(a.to == currentObject){
                int x = a.points[2].x + mousePos.x - startPoint.x;
                int y = a.points[2].y + mousePos.y - startPoint.y;
                a.points[2] = new Point(x, y);
              }
            } 
          }
          setLoopArrows();
        }
        g.clearRect(0, 0, canvas.width, canvas.height);
        renderer.render(g, objects);
        startPoint = mousePos;
      } else if(isDown && currentArrow != null){ // Holding on arrow.
        if(buttonIndex == 0){
          Point mousePos = getMousePosition(me);
          currentArrow.points[arrowPointIndex] = mousePos;
          setEdgePoints(currentArrow);
          g.clearRect(0, 0, canvas.width, canvas.height);
          renderer.render(g, objects);
          drawRedCircle(g, mousePos.x, mousePos.y);
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

  void setTwoPoints(Arrow a){
    a.points.clear();
    double angle = atan2(a.to.y - a.from.y, a.to.x - a.from.x);
    double x = a.to.width / 2 * cos(angle);
    double y = a.to.width / 2 * sin(angle);
    a.points.add(new Point(a.from.x + a.from.width / 2 + x, a.from.y + a.from.height / 2 + y));
    a.points.add(new Point(a.to.x + a.to.width / 2 - x, a.to.y + a.to.height / 2 - y));
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

  void addAt(List<Point> points, Point p, int index){
    points.add(p);
    for(int i = points.length - 1; i > index; i--){
      points[i] = points[i - 1];
    }
    points[index] = p;
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

  Point getMiddle(Point a, Point b){
    int x = a.x + (b.x - a.x) / 2;
    int y = a.y + (b.y - a.y) / 2;
    return new Point(x, y);
  }

  bool isLoopingArrow(Arrow a){
    State s = a.to;
    for(int i = 0; i < s.connections.length; i++){
      if(s.connections[i].to == a.from){
        return true;
      }
    }
    return false;
  }

  void setLoopArrows(){
    List<Arrow> doneArrows = new List<Arrow>();

    // Bend arrows that go back and forth.
    for(int i = 0; i < objects.length; i++){
      State s = objects[i];
      for(int j = 0; j < s.connections.length; j++){
        State other = s.connections[j].to;
        if(!doneArrows.contains(s.connections[j]) && s != other){
          for(int k = 0; k < other.connections.length; k++){
            if(other.connections[k].to == s && !doneArrows.contains(other.connections[k])){
              s.connections[j].points.removeAt(1);
              other.connections[k].points.removeAt(1);
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
  }
}