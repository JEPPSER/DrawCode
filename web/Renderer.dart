import 'DiagramObject.dart';
import 'Square.dart';
import 'dart:html';
import 'dart:math';

class Renderer {

  int squareWidth;
  int squareHeight;
  List<DiagramObject> doneObjects = new List<DiagramObject>();

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){

    double scale =  2.0 - (objects.length / 10);
    if(scale < 0.5){
      scale = 0.5;
    }

    squareWidth = (100 * scale).floor();
    squareHeight = (50 * scale).floor();

    g.font = (8 * scale).toString() + "px Arial";

    if(objects.length > 0){
      DiagramObject s = objects[0];
      doneObjects.add(s);
      s.width = squareWidth;
      s.height = squareHeight;
      s.x = (s.width / 2).floor();
      s.y = (755 / 2).floor();
      placeConnections(s, objects);      
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

          if(fromY < toY){
            fromY = s.y + s.height;
            toY = s.connections[j].y;
          } 
          if(toY < fromY){
            fromY = s.y;
            toY = s.connections[j].y + s.connections[j].height;
          } 
          if(fromX < toX){
            fromX = s.x + s.width;
            toX = s.connections[j].x;
          } 
          if(fromX > toX){
            fromX = s.x;
            toX = s.connections[j].x + s.connections[j].width;
          }
          drawArrow(g, fromX, fromY, toX, toY);
        }
      }
    }
    g.closePath();
    g.stroke();

    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Square){
        Square s = objects[i];
        g.strokeRect(s.x, s.y, s.width, s.height);
        g.fillText(s.text, s.x + s.width / 2, s.y + s.height / 2);
      }
    }
  }

  void placeConnections(DiagramObject o, List<DiagramObject> objects){
    if(o is Square){
      Square s = o;
      s.width = squareWidth;
      s.height = squareHeight;
      for(int i = 0; i < s.connections.length; i++){
        if(!doneObjects.contains(s.connections[i])){
          int x;
          int y;

          // Set x and y.
          if(i == 0){
           x = (s.x + s.width * 1.5).floor();
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
          if(!isFree(x, y, objects) && (x > 800 || x < 0 || y > 600 || y < 0)){
            Random rand = new Random();
            x = rand.nextInt(800);
            y = rand.nextInt(600);
          }

          doneObjects.add(s.connections[i]);
          s.connections[i].x = x;
          s.connections[i].y = y;
          placeConnections(s.connections[i], objects);
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

  bool isFree(int x, int y, List<DiagramObject> objects){
    for(int j = 0; j < objects.length; j++){
      if(objects[j].x == x && objects[j].y == y){
        return false;
      }
    }
    return true;
  }
}