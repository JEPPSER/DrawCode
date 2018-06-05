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

main(){
  TextAreaElement txtArea = querySelector('#txtArea');
  ButtonInputElement drawBtn = querySelector('#drawBtn');
  TextInputElement fileText= querySelector('#fileText');
  var fileBtn = querySelector('#fileBtn');
  var exportBtn = querySelector('#exportBtn');
  var myModal = querySelector('#myModal');
  var span = document.getElementsByClassName("close")[0];
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
    fileText.value = null;
    myModal.style.display = "block";
    fileBtn.attributes.remove('download');
    fileBtn.attributes.remove('href');
  });

  fileBtn.onClick.listen((_) {
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

    String fileName = fileText.value;
    String img = myCanvas.toDataUrl('image/png', 1);
    if(fileName != null && fileName != ""){
      fileBtn.setAttribute('download', fileName);
      fileBtn.href = img;
      myModal.style.display = "none";
    }
  });

  span.onClick.listen((_) {
    myModal.style.display = "none";
  });

  window.onClick.listen((MouseEvent e) {
    if (e.target == myModal) {
        myModal.style.display = "none";
    }
  });
}