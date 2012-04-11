module W2tagsHotVar  
  def test_hot_var_01
easy_test(<<W2TAGS____________,<<EXPECTED__________)
-# this will not translate
&var1=#this value
&var1!
W2TAGS____________
&var1!
EXPECTED__________
  end
  def test_hot_var_02
easy_test(<<W2TAGS____________,<<EXPECTED__________)
~^ $0
^ #this value;%span what!;:
W2TAGS____________
<div id="this">value</div>
<span>what!</span>
<input />
EXPECTED__________
  end
  def test_hot_var_03
easy_test(<<W2TAGS____________,<<EXPECTED__________)
&var=#this value;%span what!;:
~^ $0
^ &var!
W2TAGS____________
<div id="this">value</div>
<span>what!</span>
<input />
EXPECTED__________
  end
  def test_hot_var_04
easy_test(<<W2TAGS____________,<<EXPECTED__________)
@var=#this value;%span what!;:
@var=#this value;%li liii
~^ $0
^ @var!
W2TAGS____________
<div id="this">value</div>
<span>what!</span>
<input />
<li>liii</li>
EXPECTED__________
  end
  def test_hot_var_05
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!vars
-vars:nms#ids.class{cus="tom"}
W2TAGS____________
 :nms#ids.class{cus="tom"}
 nm=:nms
 id=#ids
 cl=.class
 at={cus="tom"}
EXPECTED__________
  end
  def test_hot_var_06
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!vars
-var2:nms#ids.class{cus="tom"}
W2TAGS____________
 :nms#ids.class{cus="tom"}
 nm=nms
 id=ids
 cl=class
 at=cus="tom"
EXPECTED__________
  end
  def test_hot_var_07
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!vars
-var3:nms#ids.class{cus="tom"}
W2TAGS____________
 name="nms" id="ids" class="class" cus="tom"
 name="nms"
 id="ids"
 class="class"
 cus="tom"
EXPECTED__________
  end
  def test_hot_var_08
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!vars
-var4= "info"
W2TAGS____________
wharsojo
<%= "info" %>
EXPECTED__________
  end
  def test_hot_var_09
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!vars
-var4== info
W2TAGS____________
wharsojo
<%= "info" %>
EXPECTED__________
  end
  def test_hot_var_10
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!vars
-var5
W2TAGS____________
_var5
EXPECTED__________
  end
  def test_hot_var_99
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-code#item1{options="rain"}= manstabs
W2TAGS____________
<span id="item1" options="rain"><%= manstabs %></span>
EXPECTED__________
  end
end
