module W2tagsEnlightning
  def test_enlightning_01
easy_test(<<W2TAGS____________,<<EXPECTED__________)
~^ $0
^ %li inli;: input
W2TAGS____________
<li>inli</li>
<input value="input"/>
EXPECTED__________
  end
  def test_enlightning_02
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!enlightning
-w %li inli;: input
W2TAGS____________
<li>inli</li>
<input value="input"/>
EXPECTED__________
  end
  def test_enlightning_03
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%ul.tabSet
  ~^ <li class="tabs off"><a href="#">$0</a></li>
  ^ Overview;200 calories
W2TAGS____________
<ul class="tabSet">
  <li class="tabs off"><a href="#">Overview</a></li>
  <li class="tabs off"><a href="#">200 calories</a></li>
</ul>
EXPECTED__________
  end
  def test_enlightning_04
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!enlightning
-w I Like ;%strong cake;!
W2TAGS____________
I Like
<strong>cake</strong>
!
EXPECTED__________
  end
end
