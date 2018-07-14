import 'dart:html';
import 'dart:math';
import 'DiagramObject.dart';
import 'State.dart';
import 'Arrow.dart';

class DFARenderer {

  void render(CanvasRenderingContext2D g, List<DiagramObject> objects){
    double scale =  2.0 - (objects.length / 10);
    if(scale < 1.4){
      scale = 1.4;
    }

    g.font = (12 * scale).toString() + "px Lucida Console";

    // Draw objects
    for(int i = 0; i < objects.length; i++){
      State s = objects[i];
      drawArrows(g, s, scale);
      drawState(g, s);
      int x = ((s.x + s.width / 2) - s.name.length * scale * 2.4).floor();
      int y = (s.y + s.height / 2 + scale * 3).floor();
      g.fillText(s.name, x, y);
    }
  }

  void drawState(CanvasRenderingContext2D g, State state){
    g.beginPath();
    g.arc(state.x + state.width / 2, state.y + state.height / 2, state.width / 2, 0, 2*PI);
    g.stroke();
    if(state.type == StateType.END){
      g.beginPath();
      g.arc(state.x + state.width / 2, state.y + state.height / 2, state.width / 2.5, 0, 2*PI);
      g.stroke();
    } else if(state.type == StateType.START){
      int fromX = state.x - 100;
      int fromY = (state.y + state.height / 2).floor();
      int toX = state.x;
      int toY = fromY;
      drawSingleArrow(g, new Point(fromX, fromY), new Point(toX, toY));
    }
  }

  void drawSingleArrow(CanvasRenderingContext2D g, Point from, Point to){
    g.beginPath();
    int headlen = 15;
    double angle = atan2(to.y - from.y, to.x - from.x);
    g.moveTo(from.x, from.y);
    g.lineTo(to.x, to.y);
    g.lineTo(to.x-headlen*cos(angle-PI/6), to.y-headlen*sin(angle-PI/6));
    g.moveTo(to.x, to.y);
    g.lineTo(to.x-headlen*cos(angle+PI/6), to.y-headlen*sin(angle+PI/6));
    g.stroke();
  }

  void drawArrows(CanvasRenderingContext2D g, State state, double scale){
    for(int i = 0; i < state.connections.length; i++){
      g.beginPath();
      Arrow a = state.connections[i];
      List<Point> points;
      if(a.points.length > 2){
        points = circularCurve(a.points);
      } else {
        points = a.points;
      }
      g.moveTo(points[0].x, points[0].y);
      for(int j = 1; j < points.length; j++){
        g.lineTo(points[j].x, points[j].y);
      }
      double angle;
      if(points.length < 2){
        angle = PI;
      } else {
        angle = getAngle(points[points.length - 2], points[points.length - 1]);
      }
      if(a.to == a.from){
        angle -= 0.15;
      }
      int headlen = 15;
      int toX = points[points.length - 1].x;
      int toY = points[points.length - 1].y;
      g.lineTo(toX-headlen*cos(angle-PI/6), toY-headlen*sin(angle-PI/6));
      g.moveTo(toX, toY);
      g.lineTo(toX-headlen*cos(angle+PI/6), toY-headlen*sin(angle+PI/6));
      Point middle;
      if(points.length > 1){
        middle = getMiddle(points[((points.length - 1) / 2).floor()], points[((points.length - 1) / 2).floor() + 1]);
      } else {
        middle = points[0];
      }
      g.stroke();
      g.setFillColorRgb(255, 255, 255);
      g.fillRect(middle.x - 10, middle.y - 10, 20, 20);
      g.setFillColorRgb(0, 0, 0);
      g.fillText(a.text, middle.x - 5, middle.y + 5);
    }
  }

  Point getMiddle(Point a, Point b){
    int x = a.x + (b.x - a.x) / 2;
    int y = a.y + (b.y - a.y) / 2;
    return new Point(x, y);
  }

  Point getCircleCenter(List<Point> points) {
		double yDelta_a = points[1].y - points[0].y;
		double xDelta_a = points[1].x - points[0].x;
		double yDelta_b = points[2].y - points[1].y;
		double xDelta_b = points[2].x - points[1].x;
    List<double> arr = new List();
    arr.add(yDelta_a);
    arr.add(xDelta_a);
    arr.add(yDelta_b);
    arr.add(xDelta_b);
		for (int i = 0; i < arr.length; i++) {
			if (arr[i] == 0) {
				arr[i] = 1.0;
			}
		}
		
		double aSlope = arr[0] / arr[1];
		double bSlope = arr[2] / arr[3];
		double x = ((aSlope * bSlope * (points[0].y - points[2].y)
				+ bSlope * (points[0].x + points[1].x) - aSlope * (points[1].x + points[2].x))
				/ (2 * (bSlope - aSlope)));
		double y = (-1 * (x - (points[0].x + points[1].x) / 2) / aSlope
				+ (points[0].y + points[1].y) / 2);
    Point center = new Point(x, y);
		return center;
	}

  bool direction(double big, double small) {
		big *= -1;
		small *= -1;
		if (big < 0 && small > 0 || big > 0 && small < 0) {
			big += PI / 2;
			small += PI / 2;
			if (big < 0) {
				big += PI * 2;
			}
			if (small < 0) {
				small += PI * 2;
			}
		}
		big = big % (PI * 2);
		small = small % (PI * 2);
		if (small < big) {
			return true;
		} else {
			return false;
		}
	}

  double getAngle(Point a, Point b){
    return atan2(b.y  - a.y, b.x - a.x);
  }

  List<Point> circularCurve(List<Point> points) {
    List<Point> list = new List<Point>();
		Point center = getCircleCenter(points);
    double big = atan2(center.y - points[0].y, center.x - points[0].x);
		double small = atan2(points[1].y - points[0].y, points[1].x - points[0].x);
    bool right = direction(big, small);
		double r = points[0].distanceTo(center);
		list.add(points[0]);

    double ang1 = getAngle(center, points[2]);
    double ang2 = getAngle(center, points[0]);
    double percent;
    if(!right){
      double temp = ang1 - ang2;
      if(temp < 0){
        temp += 2*PI;
      }
      percent = temp / (PI * 2);
    } else {
      double temp = ang2 - ang1;
      if(temp < 0){
        temp += 2*PI;
      }
      percent = temp / (PI * 2);
    }
    if(r > 100000){
      r = 1.0;
    }
    int length = (PI * r * 2 * percent).round();

    // distance between points
    double l = 1.0;

		// Angle between points
		double v = acos((r * r + l * l - r * r) / (2 * r * l));

		// Place points.
		for (int i = 0; i < length / l; i++) {
			Point a = list[list.length - 1];
			double u = atan2(center.y - a.y, center.x - a.x);
			u *= -1;
			double w = v + u;
			w *= -1;
			double y = l * sin(w);
			double x = l * cos(w);
      Point res;
      if(right){
        res = new Point(a.x - x, a.y - y);
      } else {
        res = new Point(a.x + x, a.y + y);
      }
			list.add(res);
		}

    return list;
	}
}