import 'DiagramObject.dart';
import 'Square.dart';
import 'If.dart';
import 'dart:html';
import 'dart:math';

class Renderer {

  List<DiagramObject> doneObjects = new List<DiagramObject>();

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){

    double scale =  2.0 - (objects.length / 10);
    if(scale < 0.5){
      scale = 0.5;
    }

    g.font = (8 * scale).toString() + "px Arial";

    // Set x and y for all objects.
    if(objects.length > 0){
      DiagramObject s = objects[0];
      doneObjects.add(s);
      s.x = (s.width / 2).floor();
      s.y = (755 / 2).floor();
      placeConnections(s, objects, scale);      
    }

    // Draw lines (arrows)
    g.beginPath();
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Square){
        Square s = objects[i];
        for(int j = 0; j < s.connections.length; j++){
          List<Point> points = getPoints(s, s.connections[j]);
          drawArrow(g, points[0].x, points[0].y, points[1].x, points[1].y);
        }
      } else if(objects[i] is If){
        If f = objects[i];
        List<DiagramObject> yesno = new List<DiagramObject>();
        if(f.yes != null){
          yesno.add(f.yes);
        }
        if(f.no != null){
          yesno.add(f.no);
        }
        for(int j = 0; j < yesno.length; j++){
          List<Point> points = getPoints(f, yesno[j]);
          drawArrow(g, points[0].x, points[0].y, points[1].x, points[1].y);
          if(j == 0){
            g.fillText("yes", points[2].x, points[2].y);
          } else if(j == 1){
            g.fillText("no", points[2].x, points[2].y);
          }
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
      toX = to.x + from.width;
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

  void placeConnections(DiagramObject o, List<DiagramObject> objects, double scale){
    if(o is Square){
      Square s = o;
      s.width = (s.width*scale).floor();
      s.height = (s.height*scale).floor();
      for(int i = 0; i < s.connections.length; i++){
        if(!doneObjects.contains(s.connections[i])){

          // Set x and y.
          if(isFree(s.x + s.width * 2, s.y, s.width, s.height, objects)){
            s.connections[i].x = s.x + (s.width * 2).floor();
            s.connections[i].y = s.y;
          } else if(isFree(s.x, s.y + s.height * 2, s.width, s.height, objects)){
            s.connections[i].x = s.x + (s.width / 2).floor() - (s.connections[i].width * scale / 2).floor();
            s.connections[i].y = s.y + s.height * 2;
          } else if(isFree(s.x, s.y - s.height * 2, s.width, s.height, objects)){
            s.connections[i].x = s.x + (s.width / 2).floor() - (s.connections[i].width * scale / 2).floor();
            s.connections[i].y = s.y - s.height * 2;
          } else {
            Random rand = new Random();
            s.connections[i].x = rand.nextInt(800);
            s.connections[i].y = rand.nextInt(600);
          }

          doneObjects.add(s.connections[i]);
          placeConnections(s.connections[i], objects, scale);
        }
      }
    } else if(o is If){
      If f = o;
      f.width = (f.width*scale).floor();
      f.height = (f.height*scale).floor();
      List<DiagramObject> yesno = new List<DiagramObject>();
      if(f.yes != null){
        yesno.add(f.yes);
      }
      if(f.no != null){
        yesno.add(f.no);
      }  
      for(int i = 0; i < yesno.length; i++){
        if(!doneObjects.contains(yesno[i])){
          if(isFree(f.x + f.width * 2, f.y, f.width, f.height, objects)){
            yesno[i].x = f.x + (f.width * 2.5).floor();
            yesno[i].y = f.y;
          } else if(isFree(f.x, f.y + f.height * 2, f.width, f.height, objects)){
            yesno[i].x = f.x + (f.width / 2).floor() - (yesno[i].width * scale / 2).floor();
            yesno[i].y = f.y + f.height * 2;
          } else if(isFree(f.x, f.y - f.height * 2, f.width, f.height, objects)){
            yesno[i].x = f.x + (f.width / 2).floor() - (yesno[i].width * scale / 2).floor();
            yesno[i].y = f.y - f.height * 2;
          } else {
            Random rand = new Random();
            yesno[i].x = rand.nextInt(800);
            yesno[i].y = rand.nextInt(600);
          }

          doneObjects.add(yesno[i]);
          placeConnections(yesno[i], objects, scale);
        }
      }
    }
  }

  void drawArrow(CanvasRenderingContext2D g, int fromX, int fromY, int toX, int toY){
    int headlen = 10;
    double angle = atan2(toY  - fromY, toX - fromX);
    g.moveTo(fromX, fromY);
    g.lineTo(toX, toY);
    g.lineTo(toX-headlen*cos(angle-PI/6), toY-headlen*sin(angle-PI/6));
    g.moveTo(toX, toY);
    g.lineTo(toX-headlen*cos(angle+PI/6), toY-headlen*sin(angle+PI/6));
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

      if(lineLength < s.text.length){
        int endIndex = 0;
        for(int i = lineLength; i < s.text.length; i+=lineLength){
          String str = s.text.substring(i - lineLength, i + 1);
          lines.add(str);
          endIndex = i + 1;
        }
        lines.add(s.text.substring(endIndex));
      } else {
        lines.add(s.text);
      }
      for(int i = 0; i < lines.length; i++){
        int y = (s.y + s.height / 2 + i * s.height / 8).floor();
        int x = (s.x + s.width / 10 + (lineLength - lines[i].length) * s.width / 40).floor();
        g.fillText(lines[i], x, y);
      }
    } else if(o is If){
      If s = o;
      int lineLength = (s.width / (5 * scale)).floor();
      List<String> lines = new List<String>();

      if(lineLength < s.text.length){
        int endIndex = 0;
        for(int i = lineLength; i < s.text.length; i+=lineLength){
          String str = s.text.substring(i - lineLength, i);
          lines.add(str);
          endIndex = i;
        }
        lines.add(s.text.substring(endIndex, s.text.length - 1));
      } else {
        lines.add(s.text);
      }
      for(int i = 0; i < lines.length; i++){
        int y = (s.y + s.height / 2 + i * s.height / 8).floor();
        int x = (s.x + s.width / 10 + (lineLength - lines[i].length) * s.width / 40).floor();
        g.fillText(lines[i], x, y);
      }
    }
  }

  bool isFree(int x, int y, int width, int height, List<DiagramObject> objects){
    for(int j = 0; j < objects.length; j++){
      if(objects[j].x != null && objects[j].y != null){
        Rectangle r = new Rectangle(objects[j].x, objects[j].y, objects[j].width, objects[j].height);
        Rectangle s = new Rectangle(x, y, width, height);
        if(r.intersects(s) || (x > 800 || x < 0 || y > 600 || y < 0)){
          return false;
        }
      }
    }
    return true;
  }
}