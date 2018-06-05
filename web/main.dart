import 'dart:html';
import 'FlowchartParser.dart';
import 'DiagramObject.dart';
import 'Flowchart.dart';
import 'FlowchartListener.dart';
import 'FlowchartRenderer.dart';
import 'UseCaseParser.dart';
import 'UseCaseDiagram.dart';
import 'UseCaseListener.dart';
import 'UseCaseRenderer.dart';
import 'dart:async';
import 'dart:js';

main(){
  TextAreaElement txtArea = querySelector('#txtArea');
  ButtonInputElement drawBtn = querySelector('#drawBtn');
  var exportBtn = querySelector('#exportBtn');
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

  exportBtn.onClick.listen((_) {
    g.setFillColorRgb(255, 255, 255);
    g.fillRect(0, 0, 1920, 1080);
    g.setFillColorRgb(0, 0, 0);
    String str = txtArea.value;
    if(str.startsWith("<flowchart>")){
      FlowchartRenderer renderer = new FlowchartRenderer();
      renderer.render(g, objects);
    } else if(str.startsWith("<usecase>")){
      UseCaseRenderer renderer = new UseCaseRenderer();
      renderer.render(g, objects);
    }
    String img = myCanvas.toDataUrl('image/png', 1);
    var name = context.callMethod('prompt', ['Enter file name: ', 'Untitled']);
    if(name != null && name != ""){
      exportBtn.setAttribute('download', name);
      exportBtn.href = img;
    }
  });
}