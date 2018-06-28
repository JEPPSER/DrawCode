class ExampleLoader {

  String getFlowchartExample(){
    return "<flowchart>\nStart a\nIf b\na.text=\"Lamp doesn't work\"\nb.text=\"Lamp plugged in?\"\na->b\nIf c\nc.text=\"Bulb burned out?\"\nIOBox d\nd.text=\"Plug in lamp\"\nb.yes=c\nb.no=d\nStep e\ne.text=\"Replace bulb\"\nc.yes=e\nDocument f\nf.text=\"Repair lamp\"\nc.no=f";
  }

  String getUseCaseExample(){
    return "<usecase>\nActor james\njames.text=\"James\"\nActor bond\nbond.text=\"Bond\"\njames implements bond\nUseCase a\na.text=\"Add Guest\"\nUseCase b\nb.text=\"Remove Guest\"\nUseCase c\nc.text=\"View Guest\"\nUseCase d\nd.text=\"Print Bill\"\njames->a\njames->b\nbond->b\na extends c\nd includes c\nSystem sys\nsys.text=\"system\"\nsys add a\nsys add b\nsys add c\nsys add d";
  }

  String getDFAExample(){
    return "<dfa>\n->State s1\nState s2\nState s3\nState s4\n(State) s5\nState s6\n(State) s7\nState s8\n(State) s9\nState s10\n(State) s11\ns1->s2: i\ns2->s3: a\ns2->s8: c\ns3->s3: a\ns3->s4: c\ns4->s5: b\ns4->s6: o\ns6->s6: o\ns6->s7: b\ns8->s9: b\ns8->s10: o\ns10->s10: o\ns10->s11: b\ns10->s8: a";
  }

  String getClassExample(){
    return "<class>\nClass Bank\nBank add +code\nBank add +address\nBank add +manages()\nBank add +maintains()\nInterface Account\nAccount add +number\nAccount add +balance\nAccount add +deposit()\nAccount add +withdraw()\nAccount add createTransaction()\nEnum AccountType\nAccountType add customer\nAccountType add clerk\nAccountType add executive\nPackage package\npackage add Bank\npackage add Account\npackage add AccountType\npackage.text=\"bank pkg\"\nBank(1)<>-(0..*)Account\nAccount(1)->(1)AccountType\nAccountType-->Bank";
  }
}