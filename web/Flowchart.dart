import 'DiagramObject.dart';
import 'Square.dart';
import 'If.dart';
import 'FlowchartRenderer.dart';
import 'Arrow.dart';
import 'dart:html';
import 'dart:math';

class Flowchart {

  List<DiagramObject> doneObjects = new List<DiagramObject>();

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){

    double scale =  2.0 - (objects.length / 10);
    if(scale < 1.4){
      scale = 1.4;
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

    FlowchartRenderer renderer = new FlowchartRenderer();
    renderer.render(g, objects);
  }

  void placeConnections(DiagramObject o, List<DiagramObject> objects, double scale){
    if(o is Square){
      Square s = o;
      s.width = (s.width*scale).floor();
      s.height = (s.height*scale).floor();
      for(int i = 0; i < s.connections.length; i++){
        if(!doneObjects.contains(s.connections[i].to)){

          // Set x and y.
          if(isFree(s.x + s.width * 2, s.y, s.width, s.height, objects)){
            s.connections[i].to.x = s.x + (s.width * 2).floor();
            s.connections[i].to.y = s.y;
          } else if(isFree(s.x, s.y + s.height * 2, s.width, s.height, objects)){
            s.connections[i].to.x = s.x + (s.width / 2).floor() - (s.connections[i].to.width * scale / 2).floor();
            s.connections[i].to.y = s.y + s.height * 2;
          } else if(isFree(s.x, s.y - s.height * 2, s.width, s.height, objects)){
            s.connections[i].to.x = s.x + (s.width / 2).floor() - (s.connections[i].to.width * scale / 2).floor();
            s.connections[i].to.y = s.y - s.height * 2;
          } else {
            Random rand = new Random();
            s.connections[i].to.x = rand.nextInt(800);
            s.connections[i].to.y = rand.nextInt(600);
          }

          doneObjects.add(s.connections[i].to);
          placeConnections(s.connections[i].to, objects, scale);
        }
      }
    } else if(o is If){
      If f = o;
      f.width = (f.width*scale).floor();
      f.height = (f.height*scale).floor();
      List<Arrow> yesno = new List<Arrow>();
      if(f.yes != null){
        yesno.add(f.yes);
      }
      if(f.no != null){
        yesno.add(f.no);
      }  
      for(int i = 0; i < yesno.length; i++){
        if(!doneObjects.contains(yesno[i].to)){
          if(isFree(f.x + f.width * 2, f.y, f.width, f.height, objects)){
            yesno[i].to.x = f.x + (f.width * 2.5).floor();
            yesno[i].to.y = f.y;
          } else if(isFree(f.x, f.y + f.height * 2, f.width, f.height, objects)){
            yesno[i].to.x = f.x + (f.width / 2).floor() - (yesno[i].to.width * scale / 2).floor();
            yesno[i].to.y = f.y + f.height * 2;
          } else if(isFree(f.x, f.y - f.height * 2, f.width, f.height, objects)){
            yesno[i].to.x = f.x + (f.width / 2).floor() - (yesno[i].to.width * scale / 2).floor();
            yesno[i].to.y = f.y - f.height * 2;
          } else {
            Random rand = new Random();
            yesno[i].to.x = rand.nextInt(800);
            yesno[i].to.y = rand.nextInt(600);
          }

          doneObjects.add(yesno[i].to);
          placeConnections(yesno[i].to, objects, scale);
        }
      }
    }
  }

  bool isFree(int x, int y, int width, int height, List<DiagramObject> objects){
    for(int j = 0; j < objects.length; j++){
      if(objects[j].x != null && objects[j].y != null){
        Rectangle r = new Rectangle(objects[j].x, objects[j].y, objects[j].width, objects[j].height);
        Rectangle s = new Rectangle(x, y, width, height);
        if(r.intersects(s) || (x > 1800 || x < 0 || y > 1000 || y < 0)){
          return false;
        }
      }
    }
    return true;
  }
}