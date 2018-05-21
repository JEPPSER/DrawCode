import 'dart:html';
import 'FlowchartParser.dart';
import 'DiagramObject.dart';
import 'Square.dart';

main(){
  TextAreaElement txtArea = querySelector('#txtArea');
  ButtonInputElement saveBtn = querySelector('#saveBtn');
  List<DiagramObject> objects;

  saveBtn.onClick.listen((_) {
    String str = txtArea.value;

    if(str.startsWith("<flowchart>")){
      FlowchartParser parser = new FlowchartParser();
      objects = parser.parse(str);
      for(int i = 0; i < objects.length; i++){
        if(objects[i] is Square){
          Square s = objects[i];
          print(s.name);
        }
      }
    }
  });
}