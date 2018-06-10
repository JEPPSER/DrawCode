
function getText(){
    var inner = document.getElementsByClassName('inner')[0];
    return inner.innerText;
};

function setText(string){
    var inner = document.getElementsByClassName('inner')[0];
    inner.innerText = string;
}
