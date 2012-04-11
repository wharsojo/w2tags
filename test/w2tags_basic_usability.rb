module W2tagsBasicUsability
  def test_basic_syntax_01
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%div
  %ul
    %li Add
    %li Edit
    %li Delete
W2TAGS____________
<div>
  <ul>
    <li>Add</li>
    <li>Edit</li>
    <li>Delete</li>
  </ul>
</div>
EXPECTED__________
  end
  def test_basic_syntax_02
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%div
  %ul
    ^ Add
    ^ Edit
    ^ Delete
W2TAGS____________
<div>
  <ul>
    <li>Add</li>
    <li>Edit</li>
    <li>Delete</li>
  </ul>
</div>
EXPECTED__________
  end
  def test_basic_syntax_03
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%div
  %ul
    ^ Add;Edit;Delete
W2TAGS____________
<div>
  <ul>
    <li>Add</li>
    <li>Edit</li>
    <li>Delete</li>
  </ul>
</div>
EXPECTED__________
  end
  def test_basic_syntax_04
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%div#menu
W2TAGS____________
<div id="menu">
</div>
EXPECTED__________
  end
  def test_basic_syntax_05
easy_test(<<W2TAGS____________,<<EXPECTED__________)
#menu
W2TAGS____________
<div id="menu">
</div>
EXPECTED__________
  end
  def test_basic_syntax_06
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%div.main_side
W2TAGS____________
<div class="main_side">
</div>
EXPECTED__________
  end
  def test_basic_syntax_07
easy_test(<<W2TAGS____________,<<EXPECTED__________)
.main_side
W2TAGS____________
<div class="main_side">
</div>
EXPECTED__________
  end
  def test_basic_syntax_08
easy_test(<<W2TAGS____________,<<EXPECTED__________)
#menu.main_side
  %ul
    %li.menu-item Add
    %li.menu-item Edit
    %li.menu-item Delete
W2TAGS____________
<div id="menu" class="main_side">
  <ul>
    <li class="menu-item">Add</li>
    <li class="menu-item">Edit</li>
    <li class="menu-item">Delete</li>
  </ul>
</div>
EXPECTED__________
  end
  def test_basic_syntax_09
easy_test(<<W2TAGS____________,<<EXPECTED__________)
#menu.main_side
  %ul
    ^.menu-item Add;Edit;Delete
W2TAGS____________
<div id="menu" class="main_side">
  <ul>
    <li class="menu-item">Add</li>
    <li class="menu-item">Edit</li>
    <li class="menu-item">Delete</li>
  </ul>
</div>
EXPECTED__________
  end
  def test_basic_syntax_10
easy_test(<<W2TAGS____________,<<EXPECTED__________)
#menu.main_side
  %dl
    ^.menu-item Add;Edit;Delete
W2TAGS____________
<div id="menu" class="main_side">
  <dl>
    <dt class="menu-item">Add</dt>
    <dt class="menu-item">Edit</dt>
    <dt class="menu-item">Delete</dt>
  </dl>
</div>
EXPECTED__________
  end
  # if you change html.hot >>input it will effect input test
  def test_basic_syntax_11
easy_test(<<W2TAGS____________,<<EXPECTED__________)
#form-edit
  %input:item_id{type="text"}
W2TAGS____________
<div id="form-edit">
  <input name="item_id" type="text" />
</div>
EXPECTED__________
  end
  def test_basic_syntax_12
easy_test(<<W2TAGS____________,<<EXPECTED__________)
#form-edit
  :item-id{type="text"}
W2TAGS____________
<div id="form-edit">
  <input name="item-id" type="text" />
</div>
EXPECTED__________
  end
  def test_basic_syntax_13
easy_test(<<W2TAGS____________,<<EXPECTED__________)
:item.key.id{type="text"}
W2TAGS____________
<input name="item.key.id" type="text" />
EXPECTED__________
  end
  def test_basic_syntax_14
easy_test(<<W2TAGS____________,<<EXPECTED__________)
:item.key.id#.key{type="text"}
W2TAGS____________
<input name="item.key.id" class="key" type="text" />
EXPECTED__________
  end
  def test_basic_syntax_15
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!tricky
:item.name#item_name.hilite cigar
%text:item.name#item_name.hilite cigar
%submit:item.name#item_name.hilite{on="kretek"} cigar
W2TAGS____________
<input name="item.name" id="item_name" class="hilite" value="cigar"/>
<input name="item.name" id="item_name" class="hilite" type="text" value="cigar"/>
<input name="item.name" id="item_name" class="hilite" on="kretek" type="submit" value="cigar"/>
EXPECTED__________
  end
  def test_basic_syntax_16
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%div
%div /
W2TAGS____________
<div>
</div>
<div/>
EXPECTED__________
  end
end
