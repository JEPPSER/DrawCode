import 'DiagramObject.dart';
import 'UseCaseRenderer.dart';
import 'System.dart';
import 'dart:html';
import 'dart:async';
import 'dart:math';

class UseCaseListener {

  CanvasElement canvas;
  CanvasRenderingContext2D g;
  List<DiagramObject> objects;
  bool isDown = false;
  DiagramObject currentObject;
  List<StreamSubscription> subs;
  UseCaseRenderer renderer;

  Point startPoint;

  UseCaseListener(CanvasElement canvas, CanvasRenderingContext2D g, List<DiagramObject> objects){
    this.canvas = canvas;
    this.g = g;
    this.objects = objects;
    subs = new List<StreamSubscription>();
    renderer = new UseCaseRenderer();
  }

  void listen(){
    StreamSubscription s1 = canvas.onMouseDown.listen((MouseEvent me) {
        isDown = true;
        Point mousePos = getMousePosition(me);
        for(int i = 0; i < objects.length; i++){
          if(!(objects[i] is System)){
            Rectangle r = new Rectangle(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
            if(r.containsPoint(mousePos)){
              currentObject = objects[i];
              startPoint = mousePos;
            }
          } 
        }
    });

    StreamSubscription s2 = canvas.onMouseMove.listen((MouseEvent me){
      if(isDown && currentObject != null){
        Point mousePos = getMousePosition(me);
        currentObject.x += mousePos.x - startPoint.x;
        currentObject.y += mousePos.y - startPoint.y;
        g.clearRect(0, 0, canvas.width, canvas.height);
        renderer.render(g, objects);
        startPoint = mousePos;
      }
    });

    StreamSubscription s3 = canvas.onMouseUp.listen((MouseEvent me){
      currentObject = null;
      isDown = false;
    });

    subs.add(s1);
    subs.add(s2);
    subs.add(s3);
  }

  Point getMousePosition(MouseEvent me){
    Rectangle rect = canvas.getBoundingClientRect();
    Point mousePos = new Point(me.client.x - rect.left, me.client.y - rect.top);
    return mousePos;
  }
  
  List<StreamSubscription> getSubscriptions(){
    return subs;
  }
}