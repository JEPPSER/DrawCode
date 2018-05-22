import 'dart:html';
import 'FlowchartParser.dart';
import 'DiagramObject.dart';
import 'Renderer.dart';
import 'Square.dart';
import 'If.dart';

main(){
  TextAreaElement txtArea = querySelector('#txtArea');
  ButtonInputElement saveBtn = querySelector('#saveBtn');
  CanvasElement myCanvas = querySelector('#myCanvas');
  CanvasRenderingContext2D g = myCanvas.getContext("2d");
  List<DiagramObject> objects;
  Renderer r = new Renderer();

  saveBtn.onClick.listen((_) {
    String str = txtArea.value;
    g.clearRect(0, 0, myCanvas.width, myCanvas. height);
    if(str.startsWith("<flowchart>")){
      FlowchartParser parser = new FlowchartParser();
      objects = parser.parse(str);
    }

    r.render(g, objects);
  });
}