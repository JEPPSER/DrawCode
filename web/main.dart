import 'dart:html';
import 'FlowchartParser.dart';
import 'DiagramObject.dart';
import 'Flowchart.dart';
import 'FlowchartController.dart';
import 'FlowchartRenderer.dart';
import 'UseCaseParser.dart';
import 'UseCaseDiagram.dart';
import 'UseCaseController.dart';
import 'UseCaseRenderer.dart';
import 'DFA.dart';
import 'DFAParser.dart';
import 'DFAController.dart';
import 'DFARenderer.dart';
import 'ExampleLoader.dart';
import 'If.dart';
import 'Arrow.dart';
import 'Square.dart';
import 'State.dart';
import 'Class.dart';
import 'ClassDiagram.dart';
import 'ClassParser.dart';
import 'ClassController.dart';
import 'ClassRenderer.dart';
import 'dart:async';
import 'dart:js';

main(){
  ButtonInputElement drawBtn = querySelector('#drawBtn');
  TextInputElement fileText= querySelector('#fileText');
  var fileBtn = querySelector('#fileBtn');
  var exportBtn = querySelector('#exportBtn');
  var helpBtn = querySelector('#helpBtn');
  var contactBtn = querySelector('#contactBtn');
  var myModal = querySelector('#myModal');
  var helpWindow = querySelector('#helpWindow');
  var contactWindow = querySelector('#contactWindow');
  CanvasElement myCanvas = querySelector('#myCanvas');
  CanvasRenderingContext2D g = myCanvas.getContext("2d");
  var flowchartEx = querySelector('#flowchartEx');
  var usecaseEx = querySelector('#usecaseEx');
  var dfaEx = querySelector('#dfaEx');
  var classEx = querySelector('#classEx');

  List<DiagramObject> objects;
  List<StreamSubscription> subs = new List<StreamSubscription>();
  ExampleLoader exLoader = new ExampleLoader();

  classEx.onClick.listen((_) {
    String str = exLoader.getClassExample();
    context.callMethod('setText', [str]);
    drawBtn.click();
  });

  dfaEx.onClick.listen((_) {
    String str = exLoader.getDFAExample();
    context.callMethod('setText', [str]);
    drawBtn.click();
  });

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
      FlowchartController fl = new FlowchartController(myCanvas, g, objects);
      fl.listen();
      subs = fl.getSubscriptions();
    } else if(str.startsWith("<usecase>")){
      UseCaseParser parser = new UseCaseParser();
      objects = parser.parse(str);
      UseCaseDiagram ucd = new UseCaseDiagram();
      ucd.render(g, objects);
      UseCaseController ucl = new UseCaseController(myCanvas, g, objects);
      ucl.listen();
      subs = ucl.getSubscriptions();
    } else if(str.startsWith("<dfa>")){
      DFAParser parser = new DFAParser();
      objects = parser.parse(str);
      DFA dfa = new DFA();
      dfa.render(g, objects);
      DFAController c = new DFAController(myCanvas, g, objects);
      c.listen();
      subs = c.getSubscriptions();
    } else if(str.startsWith("<class>")){
      ClassParser parser = new ClassParser();
      objects = parser.parse(str);
      ClassDiagram cd = new ClassDiagram();
      cd.render(g, objects);
      ClassController c = new ClassController(myCanvas, g, objects);
      c.listen();
      subs = c.getSubscriptions();
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

  contactBtn.onClick.listen((_) {
    contactWindow.style.display = "block";
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
    if(e.target == contactWindow){
      contactWindow.style.display = "none";
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
  } else if(str.startsWith("<dfa>")){
    DFARenderer renderer = new DFARenderer();
    renderer.render(g, objects);
  } else if(str.startsWith("<class>")){
    ClassRenderer renderer = new ClassRenderer();
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
    x = leftMostX.x - 100;
    y = topY.y - 100;
    width = rightMostX.x + rightMostX.width + 100 - x;
    height = bottomY.y + bottomY.height + 100 - y;
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
    } else if(objects[i] is State){
      State s = objects[i];
      for(int j = 0; j < s.connections.length; j++){
        Arrow a = s.connections[j];
        for(int k = 0; k < a.points.length; k++){
          a.points[k] = new Point(a.points[k].x - x, a.points[k].y - y);
        }
      }
    } else if(objects[i] is Class){
      Class s = objects[i];
      List<Arrow> connections = getConnections(s);
      for(int j = 0; j < connections.length; j++){
        Arrow a = connections[j];
        for(int k = 0; k < a.points.length; k++){
          a.points[k] = new Point(a.points[k].x - x, a.points[k].y - y);
        }
      }
    }
  }

  myCanvas.width = width;
  myCanvas.height = height;
}

List<Arrow> getConnections(Class s){
    List<Arrow> list = new List<Arrow>();
    list.addAll(s.aggregations);
    list.addAll(s.associations);
    list.addAll(s.compositions);
    list.addAll(s.dAssociations);
    list.addAll(s.dependencies);
    list.addAll(s.inheritances);
    list.addAll(s.realizations);
    return list;
}