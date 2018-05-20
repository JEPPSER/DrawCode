import 'dart:html';

main(){
  TextAreaElement txtArea = querySelector('#txtArea');
  ButtonInputElement saveBtn = querySelector('#saveBtn');
  saveBtn.onClick.listen((_) {
    String str = txtArea.value;
    print(str);
  });
}