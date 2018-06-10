class ExampleLoader {

  String getFlowchartExample(){
    return "<flowchart>\nStart a\nIf b\na.text=\"Lamp doesn't work\"\nb.text=\"Lamp plugged in?\"\na->b\nIf c\nc.text=\"Bulb burned out?\"\nIOBox d\nd.text=\"Plug in lamp\"\nb.yes=c\nb.no=d\nStep e\ne.text=\"Replace bulb\"\nc.yes=e\nDocument f\nf.text=\"Repair lamp\"\nc.no=f";
  }

  String getUseCaseExample(){
    return "<usecase>\nActor james\njames.text=\"James\"\nActor bond\nbond.text=\"Bond\"\njames implements bond\nUseCase a\na.text=\"Add Guest\"\nUseCase b\nb.text=\"Remove Guest\"\nUseCase c\nc.text=\"View Guest\"\nUseCase d\nd.text=\"Print Bill\"\njames->a\njames->b\nbond->b\na extends c\nd includes c\nSystem sys\nsys.text=\"system\"\nsys add a\nsys add b\nsys add c\nsys add d";
  }
}