import 'DiagramObject.dart';
import 'UseCaseRenderer.dart';
import 'UseCase.dart';
import 'Actor.dart';
import 'dart:html';
import 'dart:math';

class UseCaseDiagram {

  List<DiagramObject> doneObjects = new List<DiagramObject>();

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){

    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.2){
      scale = 1.2;
    }
    g.font = (8 * scale).toString() + "px Arial";

    int uCounter1 = 0;
    int uCounter2 = 0;

    Random rand = new Random();

    // Set x and y for all objects.
    if(objects.length > 0){
      for(int i = 0; i < objects.length; i++){
        objects[i].width = (objects[i].width * scale).floor();
        objects[i].height = (objects[i].height * scale).floor();
        if(objects[i] is Actor){
          Actor a = objects[i];
          a.x = 100;
          a.y = 300 + doneObjects.length * (a.height + 20);
          if(a.y > 650){
            a.y = rand.nextInt(200);
          }
          doneObjects.add(a);
        } else if(objects[i] is UseCase){
          UseCase uc = objects[i];
          bool hasActor = false;
          for(int j = 0; j < objects.length; j++){
            if(objects[j] is Actor){
              Actor act = objects[j];
              if(act.connections.contains(uc)){
                hasActor = true;
                break;
              }
            }
          }
          if(hasActor){
            uc.x = 100 + uc.width * 2;
            uc.y = 300 + uCounter1 * (uc.height + 20);
            if(uc.y > 650){
              uc.y = rand.nextInt(200);
            }
            uCounter1++;
          } else {
            uc.x = 100 + uc.width * 4;
            uc.y = 300 + uCounter2 * (uc.height + 20);
            if(uc.y > 650){
              uc.y = rand.nextInt(200);
            }
            uCounter2++;
          }
          doneObjects.add(uc);
        }
      }
    }

    UseCaseRenderer renderer = new UseCaseRenderer();
    renderer.render(g, objects);
  }
}