import 'DiagramObject.dart';
import 'Actor.dart';
import 'UseCase.dart';
import 'System.dart';
import 'dart:html';

class UseCaseRenderer {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale = 2.0 - (objects.length / 10);
    if(scale < 1.5){
      scale = 1.5;
    }
    g.font = (8 * scale).toString() + "px Arial";

    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Actor){
        g.strokeRect(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
      } else if(objects[i] is UseCase){
        g.strokeRect(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
      } else if(objects[i] is System){
        g.strokeRect(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
      }
    }
  }
}