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
import 'ExampleLoader.dart';
import 'If.dart';
import 'Arrow.dart';
import 'Square.dart';
import 'dart:async';
import 'dart:js';

main(){
  ButtonInputElement drawBtn = querySelector('#drawBtn');
  TextInputElement fileText= querySelector('#fileText');
  var fileBtn = querySelector('#fileBtn');
  var exportBtn = querySelector('#exportBtn');
  var helpBtn = querySelector('#helpBtn');
  var myModal = querySelector('#myModal');
  var helpWindow = querySelector('#helpWindow');
  CanvasElement myCanvas = querySelector('#myCanvas');
  CanvasRenderingContext2D g = myCanvas.getContext("2d");
  var flowchartEx = querySelector('#flowchartEx');
  var usecaseEx = querySelector('#usecaseEx');

  List<DiagramObject> objects;
  List<StreamSubscription> subs = new List<StreamSubscription>();
  ExampleLoader exLoader = new ExampleLoader();

  flowchartEx.onClick.listen((_) {
    String str = exLoader.getFlowchartExample();
    context.callMethod('setText', [str]);
    drawBtn.click();
  });

  usecaseEx.onClick.listen((_) {
    String str = exLoader.getUseCaseExample();
    context.callMethod('setText', [str]);
    drawBtn.click();
  });

  myCanvas.onContextMenu.listen((e) {
    e.preventDefault();
  });

  drawBtn.onClick.listen((_) {
    for(int i = 0; i < subs.length; i++){
      subs[i].cancel();
    }
    var object = context.callMethod('getText');
    String str = object;
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
    fileText.value = null;
    myModal.style.display = "block";
    fileBtn.attributes.remove('download');
    fileBtn.attributes.remove('href');
  });

  helpBtn.onClick.listen((_) {
    helpWindow.style.display = "block";
  });

  fileBtn.onClick.listen((_) {
    cropCanvas(myCanvas, objects);
    g.setFillColorRgb(255, 255, 255);
    g.fillRect(0, 0, myCanvas.width, myCanvas.height);
    g.setFillColorRgb(0, 0, 0);
    var object = context.callMethod('getText');
    String str = object;
    drawCanvas(str, g, objects);

    String fileName = fileText.value;
    String img = myCanvas.toDataUrl();
    if(fileName != null && fileName != ""){
      fileBtn.setAttribute('download', fileName);
      fileBtn.href = img;
      myModal.style.display = "none";
    }
    myCanvas.width = 1920;
    myCanvas.height = 1080;
    drawCanvas(str, g, objects);
  });

  window.onClick.listen((MouseEvent e) {
    if (e.target == myModal) {
      myModal.style.display = "none";
    }
    if(e.target == helpWindow){
      helpWindow.style.display = "none";
    }
  });
}

void drawCanvas(String str, CanvasRenderingContext2D g, List<DiagramObject> objects){
  if(str.startsWith("<flowchart>")){
    FlowchartRenderer renderer = new FlowchartRenderer();
    renderer.render(g, objects);
  } else if(str.startsWith("<usecase>")){
    UseCaseRenderer renderer = new UseCaseRenderer();
    renderer.render(g, objects);
  }
}

void cropCanvas(CanvasElement myCanvas, List<DiagramObject> objects){
  int x = 100;
  int y = 100;
  int width = 100;
  int height = 100;
  if(objects.length > 0){
    DiagramObject leftMostX = objects[0];
    DiagramObject rightMostX = objects[0];
    DiagramObject topY = objects[0];
    DiagramObject bottomY = objects[0];

    for(int j = 1; j < objects.length; j++){
      if(objects[j].x < leftMostX.x){
        leftMostX = objects[j];
      }
      if(objects[j].x + objects[j].width > rightMostX.x + rightMostX.width){
        rightMostX = objects[j];
      }
      if(objects[j].y < topY.y){
        topY = objects[j];
      }
      if(objects[j].y + objects[j].height > bottomY.y + bottomY.height){
        bottomY = objects[j];
      }
    }
    x = leftMostX.x - 50;
    y = topY.y - 50;
    width = rightMostX.x + rightMostX.width + 50 - x;
    height = bottomY.y + bottomY.height + 50 - y;
  }

  for(int i = 0; i < objects.length; i++){
    objects[i].x -= x;
    objects[i].y -= y;
    if(objects[i] is If){
      If f = objects[i];
      if(f.yes != null){
        for(int j = 0; j < f.yes.points.length; j++){
          f.yes.points[j] = new Point(f.yes.points[j].x - x, f.yes.points[j].y - y);
        }
        f.yesPoint = new Point(f.yesPoint.x - x, f.yesPoint.y - y);
      }
      if(f.no != null){
        for(int j = 0; j < f.no.points.length; j++){
          f.no.points[j] = new Point(f.no.points[j].x - x, f.no.points[j].y - y);
        }
        f.noPoint = new Point(f.noPoint.x - x, f.noPoint.y - y);
      }
    } else if(objects[i] is Square){
      Square s = objects[i];
      for(int j = 0; j < s.connections.length; j++){
        Arrow a = s.connections[j];
        for(int k = 0; k < a.points.length; k++){
          a.points[k] = new Point(a.points[k].x - x, a.points[k].y - y);
        }
      }
    }
  }

  myCanvas.width = width;
  myCanvas.height = height;
}