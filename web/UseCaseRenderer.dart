import 'DiagramObject.dart';
import 'Actor.dart';
import 'UseCase.dart';
import 'System.dart';
import 'dart:html';
import 'dart:math';

class UseCaseRenderer {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.5){
      scale = 1.5;
    }
    g.font = (8 * scale).toString() + "px Arial";

    // Draw connections
    g.beginPath();
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Actor){
        Actor a = objects[i];
        for(int j = 0; j < a.connections.length; j++){
          List<Point> points = getPoints(a, a.connections[j]);
          g.moveTo(a.x + a.width / 2, a.y + a.height / 2);
          g.lineTo(points[1].x, points[1].y);
        }
        for(int j = 0; j < a.implementations.length; j++){
          List<Point> points = getPoints(a, a.implementations[j]);
          drawImplements(g, points[0].x, points[0].y, points[1].x, points[1].y);
        }
      } else if(objects[i] is UseCase){
        UseCase uc = objects[i];
        for(int j = 0; j < uc.extensions.length; j++){
          List<Point> points = getPoints(uc, uc.extensions[j]);
          drawDottedArrow(g, points[0].x, points[0].y, points[1].x, points[1].y);
        }
        for(int j = 0; j < uc.inclusions.length; j++){
          List<Point> points = getPoints(uc, uc.inclusions[j]);
          drawDottedArrow(g, points[0].x, points[0].y, points[1].x, points[1].y);
        }
      }
    }
    g.closePath();
    g.stroke();

    // Draw objects
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Actor){
        g.strokeRect(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
      } else if(objects[i] is UseCase){
        g.strokeRect(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
      } else if(objects[i] is System){
        g.strokeRect(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
      }
    }
  }

  void drawDottedArrow(CanvasRenderingContext2D g, fromX, fromY, toX, toY){
    int headlen = 15;
    double angle = atan2(toY - fromY, toX - fromX);
    int x = (headlen * 0.9 * cos(angle)).floor();
    int y = (headlen * 0.9 * sin(angle)).floor();
    g.moveTo(fromX, fromY);
    Point point = new Point(fromX, fromY);
    int i = 0;
    while(point.distanceTo(new Point(toX, toY)) > headlen){
      point = new Point(point.x + x, point.y + y);
      if(i % 2 == 0){
        g.lineTo(point.x, point.y);
      } else {
        g.moveTo(point.x, point.y);
      }
      i++;
    }
    if(i % 2 == 0){
      g.lineTo(toX, toY);
    } else {
      g.moveTo(toX, toY);
    }
    g.lineTo(toX-headlen*cos(angle-PI/6), toY-headlen*sin(angle-PI/6));
    g.moveTo(toX, toY);
    g.lineTo(toX-headlen*cos(angle+PI/6), toY-headlen*sin(angle+PI/6));
  }

  void drawImplements(CanvasRenderingContext2D g, fromX, fromY, toX, toY){
    int headlen = 15;
    double angle = atan2(toY - fromY, toX - fromX);
    int x = (headlen * 0.9 * cos(angle)).floor();
    int y = (headlen * 0.9 * sin(angle)).floor();
    g.moveTo(fromX, fromY);
    g.lineTo(toX - x, toY - y);
    g.lineTo(toX-headlen*cos(angle-PI/6), toY-headlen*sin(angle-PI/6));
    g.lineTo(toX, toY);
    g.lineTo(toX-headlen*cos(angle+PI/6), toY-headlen*sin(angle+PI/6));
    g.lineTo(toX - x, toY - y);
  }

  List<Point> getPoints(DiagramObject from, DiagramObject to){
    List<Point> result = new List<Point>();
    int fromX = (from.x + from.width / 2).floor();
    int fromY = (from.y + from.height / 2).floor();
    int toX = (to.x + to.width / 2).floor();
    int toY = (to.y + to.height / 2).floor();

    int textX = 0;
    int textY = 0;

    double angle = atan2(toY - fromY, toX - fromX);
    if(angle < 0){
      angle += 2*PI;
    }
    angle = 2*PI - angle;

    // Shit code maybe fix later.....
    if(angle <= PI/8 || angle >= 15*PI/8){
      fromX = from.x + from.width;
      toX = to.x;
      textX = fromX + 10;
      textY = fromY - 10;
      from.hasLeft = false;
      to.hasRight = false;
    } else if(angle <= 3*PI/8 && angle >= PI/8){
      if(from.hasTop){
        fromY = from.y;
        from.hasTop = false;
        textX = fromX + 10;
        textY = fromY - 20;
      } else {
        fromX = from.x + from.width;
        from.hasRight = false;
        textX = fromX + 10;
        textY = fromY - 10;
      }
      if(to.hasRight){
        toX = to.x;
        to.hasRight = false;
      } else {
        toY = to.y + to.height;
        to.hasBottom = false;
      }
    } else if(angle <= 5*PI/8 && angle >= 3*PI/8){
      fromY = from.y;
      toY = to.y + to.height;
      textX = fromX + 10;
      textY = fromY - 20;
      from.hasTop = false;
      to.hasBottom = false;
    } else if(angle <= 7*PI/8 && angle >= 5*PI/8){
      if(from.hasTop){
        fromY = from.y;
        from.hasTop = false;
        textX = fromX - 10;
        textY = fromY - 20;
      } else {
        fromX = from.x;
        from.hasLeft = false;
        textX = fromX - 20;
        textY = fromY - 10;
      }
      if(to.hasLeft){
        toX = to.x + from.width;
        to.hasLeft = false;
      } else {
        toY = to.y + to.height;
        to.hasBottom = false;
      }
    } else if(angle <= 9*PI/8 && angle >= 7*PI/8){
      fromX = from.x;
      toX = to.x + to.width;
      textX = fromX - 20;
      textY = fromY - 10;
      from.hasLeft = false;
      to.hasRight = false;
    } else if(angle <= 11*PI/8 && angle >= 9*PI/8){
      if(from.hasBottom){
        fromY = from.y + from.height;
        textX = fromX - 20;
        textY = fromY + 10;
        from.hasBottom = false;
      } else {
        fromX = from.x;
        textX = fromX - 20;
        textY = fromY - 10;
        from.hasLeft = false;
      }
      if(to.hasRight){
        toX = to.x + to.width;
        to.hasRight = false;
      } else {
        toY = to.y;
        to.hasTop = false;
      } 
    } else if(angle <= 13*PI/8 && angle >= 11*PI/8){
      fromY = from.y + from.height;
      toY = to.y;
      textX = fromX + 10;
      textY = fromY + 20;
      from.hasBottom = false;
      to.hasTop = false;
    } else if(angle <= 15*PI/8 && angle >= 13*PI/8){
      if(from.hasBottom){
        fromY = from.y + from.height;
        textX = fromX + 10;
        textY = fromY + 20;
        from.hasBottom = false;
      } else {
        fromX = from.x + from.width;
        textX = fromX + 10;
        textY = fromY + 20;
        from.hasRight = false;
      }
      if(to.hasLeft){
        toX = to.x;
        to.hasLeft = false;
      } else {
        toY = to.y;
        to.hasTop = false;
      }
    }

    result.add(new Point(fromX, fromY));
    result.add(new Point(toX, toY));
    result.add(new Point(textX, textY));
    return result;
  }
}