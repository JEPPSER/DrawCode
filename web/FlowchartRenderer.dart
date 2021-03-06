import 'DiagramObject.dart';
import 'Square.dart';
import 'If.dart';
import 'Arrow.dart';
import 'dart:html';
import 'dart:math';

class FlowchartRenderer {

  CanvasRenderingContext2D g;
  List<DiagramObject> objects;

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale =  2.0 - (objects.length / 10);
    if(scale < 1.4){
      scale = 1.4;
    }

    g.font = (8 * scale).toString() + "px Lucida Console";

    // Draw lines (arrows)
    g.beginPath();
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Square){
        Square s = objects[i];
        for(int j = 0; j < s.connections.length; j++){
          List<Point> points = getPoints(s, s.connections[j].to);
          if(s.connections[j].points.length <= 2){
            s.connections[j].points.clear();
            s.connections[j].points.add(points[0]);
            s.connections[j].points.add(points[1]);
          }
          drawArrow(g, s.connections[j]);
        }
      } else if(objects[i] is If){
        If f = objects[i];
        List<Arrow> yesno = new List<Arrow>();
        if(f.yes != null){
          yesno.add(f.yes);
        }
        if(f.no != null){
          yesno.add(f.no);
        }
        for(int j = 0; j < yesno.length; j++){
          List<Point> points = getPoints(f, yesno[j].to);
          if(yesno[j].points.length <= 2){
            yesno[j].points.clear();
            yesno[j].points.add(points[0]);
            yesno[j].points.add(points[1]);
            if(j == 0){
              f.yesPoint = points[2];
            } else if(j == 1){
              f.noPoint = points[2];
            }
          }
          if(j == 0){
            g.fillText("yes", f.yesPoint.x, f.yesPoint.y);
          } else if(j == 1){
            g.fillText("no", f.noPoint.x, f.noPoint.y);
          }
          drawArrow(g, yesno[j]);
        }
      }
    }
    g.closePath();
    g.stroke();

    // Draw objects
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Square){
        Square s = objects[i];
        if(s.type == SquareType.STEP){
          g.strokeRect(s.x, s.y, s.width, s.height);
        } else if(s.type == SquareType.IO_BOX){
          g.beginPath();
          drawIOBox(g, s);
          g.closePath();
          g.stroke();
        } else if(s.type == SquareType.DOCUMENT){
          g.beginPath();
          drawDocument(g, s);
          g.closePath();
          g.stroke();
        } else if(s.type == SquareType.START || s.type == SquareType.END){
          g.beginPath();
          drawStart(g, s);
          g.closePath();
          g.stroke();
        }
        drawText(g, s, scale);
      } else if(objects[i] is If){
        If f = objects[i];
        g.beginPath();
        drawDiamond(g, f);
        g.closePath();
        g.stroke();
        drawText(g, f, scale);
      }
    }
  }

  void drawArrow(CanvasRenderingContext2D g, Arrow arrow){
    int headlen = 15;
    Point to = arrow.points[arrow.points.length - 1];
    Point from = arrow.points[arrow.points.length - 2];
    double angle = atan2(to.y - from.y, to.x - from.x);
    g.moveTo(arrow.points[0].x, arrow.points[0].y);
    for(int i = 1; i < arrow.points.length; i++){
      g.lineTo(arrow.points[i].x, arrow.points[i].y);
    }
    g.lineTo(to.x, to.y);
    g.lineTo(to.x-headlen*cos(angle-PI/6), to.y-headlen*sin(angle-PI/6));
    g.moveTo(to.x, to.y);
    g.lineTo(to.x-headlen*cos(angle+PI/6), to.y-headlen*sin(angle+PI/6));
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

  void drawDiamond(CanvasRenderingContext2D g, If f){
    g.moveTo(f.x, f.y + f.height / 2);
    g.lineTo(f.x + f.width / 2, f.y);
    g.lineTo(f.x + f.width, f.y + f.height / 2);
    g.lineTo(f.x + f.width / 2, f.y + f.height);
    g.lineTo(f.x, f.y + f.height / 2);
  }

  void drawIOBox(CanvasRenderingContext2D g, Square s){
    g.moveTo(s.x + s.width * 0.15, s.y);
    g.lineTo(s.x + s.width + s.width * 0.15, s.y);
    g.lineTo(s.x + s.width - s.width * 0.15, s.y + s.height);
    g.lineTo(s.x - s.width * 0.15, s.y + s.height);
    g.lineTo(s.x + s.width * 0.15, s.y);
  }

  void drawDocument(CanvasRenderingContext2D g, Square s){
    g.moveTo(s.x, s.y);
    g.lineTo(s.x + s.width, s.y);
    g.lineTo(s.x + s.width, s.y + s.height);
    g.arc(s.x + (s.width / 4) * 3, s.y + s.height * 1.3, s.width / 3, -1, PI + 0.75, true);
    g.arc(s.x + (s.width / 4), s.y + s.height * 0.7, s.width / 3, 1, PI - 0.75, false);
    g.lineTo(s.x, s.y);
  }

  void drawStart(CanvasRenderingContext2D g, Square s){
    g.moveTo(s.x + s.width - s.height / 2, s.y);
    g.arc(s.x + s.width - s.height / 2, s.y + s.height / 2, s.height / 2, 3*PI/2, PI/2, false);
    g.arc(s.x + s.height / 2, s.y + s.height / 2, s.height / 2, PI/2, 3*PI/2, false);
  }

  void drawText(CanvasRenderingContext2D g, DiagramObject o, scale){
    if(o is Square){
      Square s = o;
      int lineLength = (s.width / (5 * scale)).floor();
      List<String> lines = new List<String>();

      if(lineLength < s.text.length && s.text.contains(" ")){
        int endIndex = 0;
        int spaceIndex = 0;
        int length = 0;
        for(int i = 1; i < s.text.length; i++){
          length++;
          if(s.text[i] == " "){
            spaceIndex = i;
          }
          if(length >= lineLength && spaceIndex != 0){
            String str = s.text.substring(i - length, spaceIndex);
            length = 0;
            i = spaceIndex;
            spaceIndex = 0;
            lines.add(str);
            endIndex = i;
          }
        }
        lines.add(s.text.substring(endIndex));
      } else {
        lines.add(s.text);
      }
      for(int i = 0; i < lines.length; i++){
        int y = (s.y + s.height * 0.55 + i * s.height / 8 - (lines.length - 1) * s.height / 16).floor();
        int x = ((s.x + s.width / 2) - lines[i].length * scale * 2.4).floor();
        g.fillText(lines[i], x, y);
      }
    } else if(o is If){
      If s = o;
      int lineLength = (s.width / (5 * scale)).floor();
      List<String> lines = new List<String>();

      if(lineLength < s.text.length && s.text.contains(" ")){
        int endIndex = 0;
        int spaceIndex = 0;
        int length = 0;
        for(int i = 1; i < s.text.length; i++){
          length++;
          if(s.text[i] == " "){
            spaceIndex = i;
          }
          if(length >= lineLength && spaceIndex != 0){
            String str = s.text.substring(i - length, spaceIndex);
            length = 0;
            i = spaceIndex;
            spaceIndex = 0;
            lines.add(str);
            endIndex = i;
          }
        }
        lines.add(s.text.substring(endIndex));
      } else {
        lines.add(s.text);
      }
      for(int i = 0; i < lines.length; i++){
        int y = (s.y + s.height * 0.55 + i * s.height / 8 - (lines.length - 1) * s.height / 16).floor();
        int x = ((s.x + s.width / 2) - lines[i].length * scale * 2.4).floor();
        g.fillText(lines[i], x, y);
      }
    }
  }
}