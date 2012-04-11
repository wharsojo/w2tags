module W2tagsHot  
  def test_hots
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-code#item1{options="rain"}= manstabs
W2TAGS____________
<span id="item1" options="rain"><%= manstabs %></span>
EXPECTED__________
  end
  def test_hot_feature_01
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-d arghhh
W2TAGS____________
<div class="rows">arghhh</div>
EXPECTED__________
  end
  def test_hot_feature_02
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-d= arghhh
W2TAGS____________
<div class="rows"><%= arghhh %></div>
EXPECTED__________
  end
  def test_hot_feature_03
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-d== arghhh
W2TAGS____________
<div class="rows"><%= "arghhh" %></div>
EXPECTED__________
  end
  def test_hot_feature_04
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-x:n#i.c.x arghhh
W2TAGS____________
<x name="n" id="i" class="c x">arghhh</x>
EXPECTED__________
  end
  def test_hot_feature_05
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-y:n#i.c.x{mak="yos"} arghhh
W2TAGS____________
<x name="n" id="i" class="c x" mak="yos"><%= arghhh %></x>
EXPECTED__________
  end
  def test_hot_feature_06
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-int 12345
W2TAGS____________
<div id="54321"/>
EXPECTED__________
  end
  def test_hot_feature_08
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-form#id 67890
W2TAGS____________
<form id="id" method="post" action="<%= "67890" %>">
</form>
EXPECTED__________
  end
  def test_hot_feature_09
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-form2#widi.sky8 testing
W2TAGS____________
<form id="widi" class="sky8" method="post" action="testing.">
</form>
EXPECTED__________
  end
  def test_hot_feature_10
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-form3#widi.sky8 testing
W2TAGS____________
<form id="widi" class="sky8" method="post" action="testing{}{}{}.">
</form>
EXPECTED__________
  end    
end
