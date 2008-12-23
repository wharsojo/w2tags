wh.init2.push("wh.treeInitEven()");
wh.treeInitEven = function(){};
wh.treeInit = function(id,s){
  var t= {};
  var a= s.split(' ');
  t.obj= $(id)[0];
  t.evn= a;
  
  for(var i in a){ var s = a[i];
    t[s] = function(x){alert('event:'+x)};
  }
  
  t.itemD= $('#dmy')[0].cloneNode(true);
  t.itemD.id='';
  
  t.items= function(arr){
    var oldP = this.par;
    var olPP = this.par.parentNode;
    var newP = this.par.cloneNode(false);
    for(var idx in arr){ var s = arr[idx];
      newP.appendChild(this.cloneItem(s));
    };
    olPP.replaceChild(newP,oldP);
  }
  
  t.getItems = function(){
    var rtn  = [];
    var items= this.par.childNodes;
    for(idx in items){ var item = items[idx];
      rtn.push(item.firstChild.firstChild.attributes.label.nodeValue);
    };
    return rtn;
  }
  
  t.addItem= function(s){
    this.par.appendChild(this.cloneItem(s));
  }
  
  t.cloneItem= function(s){
    var item = this.itemD.cloneNode(true);
    var cell = item.firstChild.firstChild;
    cell.attributes.label.nodeValue= s;
    cell.className= this.class;
    return item;
  }
  
  t.curCell= function(){
    this.item = this.obj.contentView.getItemAtIndex(this.obj.currentIndex);
    this.cell = this.item.firstChild.firstChild;
    this.par  = this.item.parentNode;  
    this.jq   = $(this.cell);
    this.class= this.jq.attr('class');
    return this.jq;
  };
  
  t.doClick = function(){
    this.curCell();
    if(this.evn.indexOf(this.class)>-1){
      this[this.class](this.class);
    }
  };
  
  t.addEvent = function(e_key,e_fn){
    this.evn.push(e_key);
    this[e_key] = e_fn;
  }
  
  this[id] = t;
  return t;
}
