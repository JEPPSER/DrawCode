import 'dart:html';
import 'FlowchartParser.dart';
import 'DiagramObject.dart';
import 'Flowchart.dart';
import 'FlowchartListener.dart';
import 'UseCaseParser.dart';
import 'UseCaseDiagram.dart';
import 'UseCaseListener.dart';
import 'dart:async';

main(){
  TextAreaElement txtArea = querySelector('#txtArea');
  ButtonInputElement drawBtn = querySelector('#drawBtn');
  CanvasElement myCanvas = querySelector('#myCanvas');
  CanvasRenderingContext2D g = myCanvas.getContext("2d");
  List<DiagramObject> objects;
  List<StreamSubscription> subs = new List<StreamSubscription>();

  drawBtn.onClick.listen((_) {
    for(int i = 0; i < subs.length; i++){
      subs[i].cancel();
    }
    String str = txtArea.value;
    g.clearRect(0, 0, myCanvas.width, myCanvas.height);
    if(str.startsWith("<flowchart>")){
      FlowchartParser parser = new FlowchartParser();
      objects = parser.parse(str);
      Flowchart r = new Flowchart();
      r.render(g, objects);
      FlowchartListener fl = new FlowchartListener(myCanvas, g, objects);
      fl.listen();
      subs = fl.getSubscriptions();
    } else if(str.startsWith("<usecase>")){
      UseCaseParser parser = new UseCaseParser();
      objects = parser.parse(str);
      UseCaseDiagram ucd = new UseCaseDiagram();
      ucd.render(g, objects);
      UseCaseListener ucl = new UseCaseListener(myCanvas, g, objects);
      ucl.listen();
      subs = ucl.getSubscriptions();
    }
  });
}