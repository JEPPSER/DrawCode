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
    
    g.beginPath();
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Square){
        Square s = objects[i];
        for(int j = 0; j < s.connections.length; j++){
          
          g.moveTo(s.x + s.width / 2, s.y + s.height / 2);
          g.lineTo(s.connections[j].x + s.connections[j].width / 2, s.connections[j].y + s.connections[j].height / 2);
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
            y = (s.y - s.width * 1.5).floor();
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

  bool isFree(int x, int y, List<DiagramObject> objects){
    for(int j = 0; j < objects.length; j++){
      if(objects[j].x == x && objects[j].y == y){
        return false;
      }
    }
    return true;
  }
}