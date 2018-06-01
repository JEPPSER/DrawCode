import 'DiagramObject.dart';
import 'Actor.dart';
import 'UseCase.dart';
import 'System.dart';
import 'dart:html';
import 'dart:math';

class UseCaseRenderer {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.3){
      scale = 1.3;
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
          List<Point> points = getPoints(a, a.implementations[j]);
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
        } else if(sys.useCases[j].x > rightMostX.x){
          rightMostX = sys.useCases[j];
        }
        if(sys.useCases[j].y < topY.y){
          topY = sys.useCases[j];
        } else if(sys.useCases[j].y > bottomY.y){
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

  void drawText(CanvasRenderingContext2D g, UseCase uc, scale){
    int lineLength = (uc.width / (5 * scale)).floor();
    List<String> lines = new List<String>();

    if(lineLength < uc.text.length){
      int endIndex = 0;
      for(int i = lineLength; i < uc.text.length; i+=lineLength){
        String str = uc.text.substring(i - lineLength, i);
        lines.add(str);
        endIndex = i;
      }
      lines.add(uc.text.substring(endIndex));
    } else {
      lines.add(uc.text);
    }
    for(int i = 0; i < lines.length; i++){
      int y = (uc.y + uc.height / 2 + i * uc.height / 8).floor();
      int x = ((uc.x + uc.width / 2) - lines[i].length * scale * 1.9).floor();
      g.fillText(lines[i], x, y);
    }
  }
}