import 'dart:html';
import 'DiagramObject.dart';
import 'Class.dart';
import 'Package.dart';
import 'Arrow.dart';
import 'Association.dart';

class ClassRenderer {

  double scale;

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    scale = 2.0 - (objects.length / 10);
    if(scale < 1.2){
      scale = 1.2;
    }
    g.font = (8 * scale).toString() + "px Arial";

    g.beginPath();

    // Draw Arrows
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Class){
        Class s = objects[i];
        for(int j = 0; j < s.inheritances.length; j++){
          Arrow arrow = s.inheritances[j];
          if(arrow.points.length < 3){
            setArrowPoints(arrow);
          }
          drawInheritance(g, arrow);
        }
        for(int j = 0; j < s.dependencies.length; j++){
          Arrow arrow = s.dependencies[j];
          if(arrow.points.length < 3){
            setArrowPoints(arrow);
          }
          drawDependancy(g, arrow);
        }
        for(int j = 0; j < s.realizations.length; j++){
          Arrow arrow = s.realizations[j];
          if(arrow.points.length < 3){
            setArrowPoints(arrow);
          }
          drawRealization(g, arrow);
        }
        for(int j = 0; j < s.associations.length; j++){
          Association a = s.associations[j];
          if(a.points.length < 3){
            setArrowPoints(a);
          }
          drawAssociation(g, a);
        }
        for(int j = 0; j < s.dAssociations.length; j++){
          Association a = s.dAssociations[j];
          if(a.points.length < 3){
            setArrowPoints(a);
          }
          drawDAssociation(g, a);
        }
        for(int j = 0; j < s.aggregations.length; j++){
          Association a = s.aggregations[j];
          if(a.points.length < 3){
            setArrowPoints(a);
          }
          drawAggregation(g, a);
        }
        for(int j = 0; j < s.compositions.length; j++){
          Association a = s.compositions[j];
          if(a.points.length < 3){
            setArrowPoints(a);
          }
          drawComposition(g, a);
        }
      }   
    }

    // Draw objects
    for(int i = 0; i < objects.length; i++){
      if(objects[i] is Class){
        Class s = objects[i];
        if(s.type == ClassType.CLASS){
          drawClass(g, s);
        } else if(s.type == ClassType.ENUM){
          drawEnum(g, s);
        } else if(s.type == ClassType.INTERFACE){
          drawInterface(g, s);
        }
      } else if(objects[i] is Package){
        Package p = objects[i];
        setPackagePosition(p, objects);
        drawPackage(g, p); 
      }
    }

    g.stroke();
  }

  void drawComposition(CanvasRenderingContext2D g, Association a){
    g.moveTo(a.points[0].x, a.points[0].y);
    for(int i = 1; i < a.points.length; i++){
      g.lineTo(a.points[i].x, a.points[i].y);
    }
  }

  void drawAggregation(CanvasRenderingContext2D g, Association a){
    g.moveTo(a.points[0].x, a.points[0].y);
    for(int i = 1; i < a.points.length; i++){
      g.lineTo(a.points[i].x, a.points[i].y);
    }
  }

  void drawDAssociation(CanvasRenderingContext2D g, Association a){
    g.moveTo(a.points[0].x, a.points[0].y);
    for(int i = 1; i < a.points.length; i++){
      g.lineTo(a.points[i].x, a.points[i].y);
    }
  }

  void drawAssociation(CanvasRenderingContext2D g, Association a){
    g.moveTo(a.points[0].x, a.points[0].y);
    for(int i = 1; i < a.points.length; i++){
      g.lineTo(a.points[i].x, a.points[i].y);
    }
  }

  void drawRealization(CanvasRenderingContext2D g, Arrow a){
    g.moveTo(a.points[0].x, a.points[0].y);
    for(int i = 1; i < a.points.length; i++){
      g.lineTo(a.points[i].x, a.points[i].y);
    }
  }

  void drawDependancy(CanvasRenderingContext2D g, Arrow a){
    g.moveTo(a.points[0].x, a.points[0].y);
    for(int i = 1; i < a.points.length; i++){
      g.lineTo(a.points[i].x, a.points[i].y);
    }
  }

  void drawInheritance(CanvasRenderingContext2D g, Arrow a){
    g.moveTo(a.points[0].x, a.points[0].y);
    for(int i = 1; i < a.points.length; i++){
      g.lineTo(a.points[i].x, a.points[i].y);
    }
  }

  void setArrowPoints(Arrow a){
    a.points.clear();
    a.points.add(new Point(a.from.x + a.from.width / 2, a.from.y + a.from.height / 2));
    a.points.add(new Point(a.to.x + a.to.width / 2, a.to.y + a.to.height / 2));
  }

  void drawPackage(CanvasRenderingContext2D g, Package p){
    g.strokeRect(p.x, p.y, p.width, p.height);
    g.moveTo(p.x, p.y + scale * 12);
    String text;
    if(p.text == null){
      text = p.name;
    } else {
      text = p.text;
    }
    g.lineTo(p.x + text.length * scale * 4, p.y + scale * 12);
    g.lineTo(p.x + text.length * scale * 4 + scale * 5, p.y + scale * 6);
    g.lineTo(p.x + text.length * scale * 4 + scale * 5, p.y);
    g.fillText(text, p.x + scale * 2, p.y + scale * 8);
  }

  void setPackagePosition(Package p, List<DiagramObject> objects){
    if(p.classes.length > 0){
      Class leftMostX = p.classes[0];
      Class rightMostX = p.classes[0];
      Class topY = p.classes[0];
      Class bottomY = p.classes[0];
      for(int j = 1; j < p.classes.length; j++){
        if(p.classes[j].x < leftMostX.x){
          leftMostX = p.classes[j];
        }
        if(p.classes[j].x + p.classes[j].width > rightMostX.x + rightMostX.width){
          rightMostX = p.classes[j];
        }
        if(p.classes[j].y < topY.y){
          topY = p.classes[j];
        }
        if(p.classes[j].y + p.classes[j].height > bottomY.y + bottomY.height){
          bottomY = p.classes[j];
        }
      }
      p.x = leftMostX.x - 50;
      p.y = topY.y - 50;
      p.width = rightMostX.x + rightMostX.width + 50 - p.x;
      p.height = bottomY.y + bottomY.height + 50 - p.y;
    }
  }

  void drawEnum(CanvasRenderingContext2D g, Class s){
    g.strokeRect(s.x, s.y, s.width, s.height);
    g.moveTo(s.x, s.y + scale * 10 * 2);
    g.lineTo(s.x + s.width, s.y + scale * 10 * 2);
    int textX1 = ((s.x + s.width / 2) - 15 * scale * 2.1).floor();
    int textX2 = ((s.x + s.width / 2) - s.name.length * scale * 2.4).floor();
    g.fillText("<<enumeration>>", textX1, s.y + scale * 8);
    g.font = "bold " + (8 * scale).toString() + "px Arial";
    g.fillText(s.name, textX2, s.y + scale * 8 * 2);
    g.font = (8 * scale).toString() + "px Arial";
    for(int i = 0; i < s.members.length; i++){
      double x = s.x + scale * 2;
      double y = s.y + scale * 10 * (i + 3) - scale * 2;
      g.fillText(s.members[i], x, y);
    }
  }

  void drawInterface(CanvasRenderingContext2D g, Class s){
    g.strokeRect(s.x, s.y, s.width, s.height);
    g.moveTo(s.x, s.y + scale * 10 * 2);
    g.lineTo(s.x + s.width, s.y + scale * 10 * 2);
    int textX1 = ((s.x + s.width / 2) - 13 * scale * 1.9).floor();
    int textX2 = ((s.x + s.width / 2) - s.name.length * scale * 2.4).floor();
    g.fillText("<<interface>>", textX1, s.y + scale * 8);
    g.font = "bold " + (8 * scale).toString() + "px Arial";
    g.fillText(s.name, textX2, s.y + scale * 8 * 2);
    g.font = (8 * scale).toString() + "px Arial";
    List<String> field = new List<String>();
    List<String> methods = new List<String>();
    for(int j = 0; j < s.members.length; j++){
      if(s.members[j].contains("(") && s.members[j].contains(")")){
        methods.add(s.members[j]);
      } else {
        field.add(s.members[j]);
      }
    }
    int j;
    for(j = 0; j < field.length; j++){
      double x = s.x + scale * 2;
      double y = s.y + scale * 10 * (j + 3) - scale * 2;
      g.fillText(field[j], x, y);
    }
    double nwY = s.y + scale * 10 * (j + 2);
    g.moveTo(s.x, nwY);
    g.lineTo(s.x + s.width, nwY);
    for(j = 0; j < methods.length; j++){
      double x = s.x + scale * 2;
      double y = nwY + scale * 10 * (j + 1) - scale * 2;
      g.fillText(methods[j], x, y);
    }
  }

  void drawClass(CanvasRenderingContext2D g, Class s){
    g.strokeRect(s.x, s.y, s.width, s.height);
    g.moveTo(s.x, s.y + scale * 10);
    g.lineTo(s.x + s.width, s.y + scale * 10);
    List<String> field = new List<String>();
    List<String> methods = new List<String>();
    for(int j = 0; j < s.members.length; j++){
      if(s.members[j].contains("(") && s.members[j].contains(")")){
        methods.add(s.members[j]);
      } else {
        field.add(s.members[j]);
      }
    }
    g.font = "bold " + (8 * scale).toString() + "px Arial";
    int textX = ((s.x + s.width / 2) - s.name.length * scale * 2.4).floor();
    g.fillText(s.name, textX, s.y + scale * 8);
    g.font = (8 * scale).toString() + "px Arial";
    int j;
    for(j = 0; j < field.length; j++){
      double x = s.x + scale * 2;
      double y = s.y + scale * 10 * (j + 2) - scale * 2;
      g.fillText(field[j], x, y);
    }
    double nwY = s.y + scale * 10 * (j + 1);
    g.moveTo(s.x, nwY);
    g.lineTo(s.x + s.width, nwY);
    for(j = 0; j < methods.length; j++){
      double x = s.x + scale * 2;
      double y = nwY + scale * 10 * (j + 1) - scale * 2;
      g.fillText(methods[j], x, y);
    }
  }
}