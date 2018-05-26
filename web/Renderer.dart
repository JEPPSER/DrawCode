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
          int fromX = (s.x + s.width / 2).floor();
          int fromY = (s.y + s.height / 2).floor();
          int toX = (s.connections[j].x + s.connections[j].width / 2).floor();
          int toY = (s.connections[j].y + s.connections[j].height / 2).floor();
          drawArrow(g, fromX, fromY, toX, toY);
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
          int fromX = (f.x + f.width / 2).floor();
          int fromY = (f.y + f.height / 2).floor();
          int toX = (yesno[j].x + yesno[j].width / 2).floor();
          int toY = (yesno[j].y + yesno[j].height / 2).floor();
          drawArrow(g, fromX, fromY, toX, toY);
        }
      }
    }
    g.closePath();
    g.stroke();

    // Draw objects
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Square){
        Square s = objects[i];
        g.strokeRect(s.x, s.y, s.width, s.height);
        g.fillText(s.text, s.x + s.width / 2, s.y + s.height / 2);
      } else if(objects[i] is If){
        If f = objects[i];
        g.beginPath();
        g.arc(f.x + f.width / 2, f.y + f.width / 2, f.width / 2, 0, 2*PI);
        g.closePath();
        g.stroke();
        g.fillText(f.text, f.x + f.width / 2, f.y + f.height / 2);
      }
    }
  }

  void placeConnections(DiagramObject o, List<DiagramObject> objects, double scale){
    if(o is Square){
      Square s = o;
      s.width = (s.width*scale).floor();
      s.height = (s.height*scale).floor();
      for(int i = 0; i < s.connections.length; i++){
        if(!doneObjects.contains(s.connections[i])){
          int x = 0;
          int y = 0;

          // Set x and y.
          if(i == 0){
           x = (s.x + s.width * 1.7).floor();
           y = s.y;
          } else if(i == 1){
            x = s.x;
            y = (s.y + s.height * 2).floor();
          } else if(i == 2){
            x = s.x;
            y = (s.y - s.height * 2).floor();
          } else{
            Random rand = new Random();
            x = rand.nextInt(800);
            y = rand.nextInt(600);
          }

          // Check if point is valid.
          if(!isFree(x, y, s.connections[i].width, s.connections[i].height, objects)){
            Random rand = new Random();
            x = rand.nextInt(800);
            y = rand.nextInt(600);
          }

          s.connections[i].x = x;
          s.connections[i].y = y;
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