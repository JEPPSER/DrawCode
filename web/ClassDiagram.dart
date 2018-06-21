import 'dart:html';
import 'dart:math';
import 'DiagramObject.dart';
import 'ClassRenderer.dart';
import 'Class.dart';

class ClassDiagram {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.2){
      scale = 1.2;
    }
    g.font = (8 * scale).toString() + "px Arial";

    Random rand = new Random();

    // Set size of all objects.
    for(int i = 0; i < objects.length; i++){
      Class s = objects[i];
      if(s.type == ClassType.CLASS){
        int memberHeight = (s.members.length * 10 * scale).round();
        int width = 0;
        for(int j = 0; j < s.members.length; j++){
          if(s.members[j].length > width){
            width = s.members[j].length;
          }
        }
        if(s.name.length > width){
          width = s.name.length;
        }
        width *= (7 * scale).round();
        if(width < scale * 50){
          width = (scale * 50).round();
        }
        s.width = width;
        s.height = (scale * 10 + memberHeight).round();
      } else if(s.type == ClassType.ENUM){

      } else if(s.type == ClassType.INTERFACE){

      }
    }

    // Set x and y for all objects.
    if(objects.length > 0){
      for(int i = 0; i < objects.length; i++){
        objects[i].x = rand.nextInt(800);
        objects[i].y = rand.nextInt(500);
      }
    }

    ClassRenderer renderer = new ClassRenderer();
    renderer.render(g, objects);
  }
}