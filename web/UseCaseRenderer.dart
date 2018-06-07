import 'DiagramObject.dart';
import 'Actor.dart';
import 'UseCase.dart';
import 'System.dart';
import 'dart:html';
import 'dart:math';

class UseCaseRenderer {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.2){
      scale = 1.2;
    }
    g.font = (8 * scale).toString() + "px Arial";

    g.beginPath();

    // Draw connections
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Actor){
        Actor a = objects[i];
        for(int j = 0; j < a.connections.length; j++){
          UseCase u = new UseCase();
          u.x = a.x;
          u.y = a.y;
          u.width = 1;
          u.height = 1;
          List<Point> points = getUseCasePoints(u, a.connections[j]);
          g.moveTo(a.x + a.width / 2, a.y + a.height / 2);
          g.lineTo(points[1].x, points[1].y);
        }
        for(int j = 0; j < a.implementations.length; j++){
          UseCase u1 = new UseCase();
          u1.x = a.x;
          u1.y = a.y;
          u1.width = a.width;
          u1.height = a.height;
          UseCase u2 = new UseCase();
          u2.x = a.implementations[j].x;
          u2.y = a.implementations[j].y;
          u2.width = a.implementations[j].width;
          u2.height = a.implementations[j].height;
          List<Point> points = getUseCasePoints(u1, u2);
          drawImplements(g, points[0].x, points[0].y, points[1].x, points[1].y);
        }
      } else if(objects[i] is UseCase){
        UseCase uc = objects[i];
        for(int j = 0; j < uc.extensions.length; j++){
          List<Point> points = getUseCasePoints(uc, uc.extensions[j]);
          drawDottedArrow(g, points[0].x, points[0].y, points[1].x, points[1].y);
          int x = points[0].x + (points[1].x - points[0].x) / 2;
          int y = points[0].y + (points[1].y - points[0].y) / 2 - 5;
          x = (x - 10 * scale * 1.9).floor();
          g.fillText("<<extend>>", x, y);
        }
        for(int j = 0; j < uc.inclusions.length; j++){
          List<Point> points = getUseCasePoints(uc, uc.inclusions[j]);
          drawDottedArrow(g, points[0].x, points[0].y, points[1].x, points[1].y);
          int x = points[0].x + (points[1].x - points[0].x) / 2;
          int y = points[0].y + (points[1].y - points[0].y) / 2 - 5;
          x = (x - 11 * scale * 1.9).floor();
          g.fillText("<<include>>", x, y);
        }
      }
    }

    // Draw objects
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Actor){
        Actor actor = objects[i];
        if(actor.text == null){
          actor.text = " ";
        }
        drawActor(g, actor);
        int x = ((actor.x + actor.width / 2) - actor.text.length * scale * 1.9).floor();
        g.fillText(actor.text, x, actor.y + actor.height);
      } else if(objects[i] is UseCase){
        UseCase uc = objects[i];
        if(uc.text == null){
          uc.text = " ";
        }
        drawUseCase(g, uc);
        drawText(g, uc, scale);
      } else if(objects[i] is System){
        System sys = objects[i];
        setSystemPosition(sys);
        if(sys.text == null){
          sys.text = " ";
        }
        g.rect(sys.x, sys.y, sys.width, sys.height);
        int x = ((sys.x + sys.width / 2) - sys.text.length * scale * 1.9).floor();
        g.fillText(sys.text, x, sys.y + 20);
      }
    }

    g.closePath();
    g.stroke();
  }

  List<Point> getUseCasePoints(UseCase from, UseCase to){
    List<Point> points = new List<Point>();
    double angle = atan2(to.y - from.y, to.x - from.x);
    if(angle < 0){
      angle += 2*PI;
    }
    double a = to.width / 2;
    double b = to.height / 2;
    double radius = (a * b) / sqrt(a*a * sin(angle)*sin(angle) + b*b * cos(angle)*cos(angle));
    double x = radius * cos(angle);
    double y = radius * sin(angle);
    points.add(new Point(from.x + from.width / 2 + x, from.y + from.height / 2 + y));
    points.add(new Point(to.x + to.width / 2 - x, to.y + to.height / 2 - y));
    return points;
  }

  void setSystemPosition(System sys){
    if(sys.useCases.length > 0){
      UseCase leftMostX = sys.useCases[0];
      UseCase rightMostX = sys.useCases[0];
      UseCase topY = sys.useCases[0];
      UseCase bottomY = sys.useCases[0];
      for(int j = 1; j < sys.useCases.length; j++){
        if(sys.useCases[j].x < leftMostX.x){
          leftMostX = sys.useCases[j];
        }
        if(sys.useCases[j].x + sys.useCases[j].width > rightMostX.x + rightMostX.width){
          rightMostX = sys.useCases[j];
        }
        if(sys.useCases[j].y < topY.y){
          topY = sys.useCases[j];
        }
        if(sys.useCases[j].y + sys.useCases[j].height > bottomY.y + bottomY.height){
          bottomY = sys.useCases[j];
        }
      }
      sys.x = leftMostX.x - 50;
      sys.y = topY.y - 50;
      sys.width = rightMostX.x + rightMostX.width + 50 - sys.x;
      sys.height = bottomY.y + bottomY.height + 50 - sys.y;
    }
  }

  void drawUseCase(CanvasRenderingContext2D g, UseCase uc){
    g.moveTo(uc.x + uc.width, uc.y + uc.height / 2);
    g.ellipse(uc.x + uc.width / 2, uc.y + uc.height / 2, uc.width / 2, uc.height / 2,
       0, 0, 2*PI, false);
  }

  void drawActor(CanvasRenderingContext2D g, Actor actor){
    int x = (actor.x + actor.width * 0.1).floor();
    int y = (actor.y + actor.height * 0.1).floor();
    int width = (actor.width * 0.8).floor();
    int height = (actor.height * 0.8).floor();
    g.moveTo(x, y + height);
    g.lineTo(x + width / 2, y + height * 0.7);
    g.moveTo(x + width , y + height);
    g.lineTo(x + width / 2, y + height * 0.7);
    g.lineTo(x + width / 2, y + height * 0.3);
    g.moveTo(x, y + height * 0.4);
    g.lineTo(x + width, y + height * 0.4);
    g.moveTo(x + width / 2, y + height * 0.3);
    g.arc(x + width / 2, y + height * 0.15, height * 0.15,
       PI/2, -3*PI/2, false);
  }

  void drawDottedArrow(CanvasRenderingContext2D g, fromX, fromY, toX, toY){
    int headlen = 15;
    double angle = atan2(toY - fromY, toX - fromX);
    double x = headlen * 0.9 * cos(angle);
    double y = headlen * 0.9 * sin(angle);
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

  void drawText(CanvasRenderingContext2D g, UseCase uc, scale){
    int lineLength = (uc.width / (5 * scale)).floor();
    List<String> lines = new List<String>();

    if(lineLength < uc.text.length && uc.text.contains(" ")){
      int endIndex = 0;
      int spaceIndex = 0;
      int length = 0;
      for(int i = 1; i < uc.text.length; i++){
        length++;
        if(uc.text[i] == " "){
          spaceIndex = i;
        }
        if(length >= lineLength && spaceIndex != 0){
          String str = uc.text.substring(i - length, spaceIndex);
          length = 0;
          i = spaceIndex;
          spaceIndex = 0;
          lines.add(str);
          endIndex = i;
        }
      }
      lines.add(uc.text.substring(endIndex));
    } else {
      lines.add(uc.text);
    }
    for(int i = 0; i < lines.length; i++){
      int y = (uc.y + uc.height * 0.55 + i * uc.height / 8 - (lines.length - 1) * uc.height / 16).floor();
      int x = ((uc.x + uc.width / 2) - lines[i].length * scale * 1.9).floor();
      g.fillText(lines[i], x, y);
    }
  }
}