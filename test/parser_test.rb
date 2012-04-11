require 'test/unit'
require 'rubygems'
require 'w2tags'
require 'w2tags_no_parsing'
require 'w2tags_basic_usability'
require 'w2tags_form'
require 'w2tags_hot'
require 'w2tags_hot_var'
require 'w2tags_enlightning'

class ParserTest < Test::Unit::TestCase

  W2TAGS = W2Tags::Parser.new
  W2TAGS.silent= true
  
  include W2tagsNoParsing
  include W2tagsBasicUsability    
  include W2tagsForm
  include W2tagsHotVar
  include W2tagsEnlightning
  
  def test_haml_like
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%div dodol
%div garut
W2TAGS____________
<div>dodol</div>
<div>garut</div>
EXPECTED__________
      
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%div
  %div garut
W2TAGS____________
<div>
  <div>garut</div>
</div>
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
%div#container
  %div.daerah garut
W2TAGS____________
<div id="container">
  <div class="daerah">garut</div>
</div>
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
#container
  .daerah garut
  #di.jawa barat
W2TAGS____________
<div id="container">
  <div class="daerah">garut</div>
  <div id="di" class="jawa">barat</div>
</div>
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
#ids.dodol.garut
  #ids.dodol.garut/
W2TAGS____________
<div id="ids" class="dodol garut">
  <div id="ids" class="dodol garut"/>
</div>
EXPECTED__________
      
easy_test(<<W2TAGS____________,<<EXPECTED__________)
#ids.dodol.garut{kota="malang"}
  #ids.dodol.garut{kota="malang"} /
W2TAGS____________
<div id="ids" class="dodol garut" kota="malang">
  <div id="ids" class="dodol garut" kota="malang"/>
</div>
EXPECTED__________

  end
  
  def test_next_tags
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%html
  ^ 
W2TAGS____________
<html>
  <head>
  </head>
</html>
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
%ul
  ^ list 1;list 2
%ol
  ^ list 1;list 2
W2TAGS____________
<ul>
  <li>list 1</li>
  <li>list 2</li>
</ul>
<ol>
  <li>list 1</li>
  <li>list 2</li>
</ol>
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
%dl
  ^ list 1;list 2
%dd
  ^ list 1;list 2
W2TAGS____________
<dl>
  <dt>list 1</dt>
  <dt>list 2</dt>
</dl>
<dd>
  <dt>list 1</dt>
  <dt>list 2</dt>
</dd>
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
%select
  ^{value="1"} list 1
  ^{value="2"} list 2
W2TAGS____________
<select>
  <option value="1">list 1</option>
  <option value="2">list 2</option>
</select>
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
%form
  ^ 1
  ^ 2
W2TAGS____________
<form>
  <input value="1"/>
  <input value="2"/>
</form>
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
%table
  %tr
    ^ header 1;header 2
  %tr
    ^ column 1;column 2
W2TAGS____________
<table>
  <tr>
    <th>header 1</th>
    <th>header 2</th>
  </tr>
  <tr>
    <td>column 1</td>
    <td>column 2</td>
  </tr>
</table>
EXPECTED__________
  end
  
  def test_w2tags
easy_test(<<W2TAGS____________,<<EXPECTED__________)
:names
W2TAGS____________
<input name="names" />
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
:names#ids.classes OK
W2TAGS____________
<input name="names" id="ids" class="classes" value="OK"/>
EXPECTED__________
  end
  
  def test_hot_htm
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%js jquery
-js liveclick
W2TAGS____________
<script type="text/javascript" src="jquery.js" > </script>
<script type="text/javascript" src="liveclick.js" > </script>
EXPECTED__________

easy_test(<<W2TAGS____________,<<EXPECTED__________)
%css base
-css layout
W2TAGS____________
<link rel="stylesheet" href="base.css" type="text/css" media="screen, projection" />
<link rel="stylesheet" href="layout.css" type="text/css" media="screen, projection" />
EXPECTED__________
  end
  
  private
  
  def easy_test(w2tg,expected)
    assert_equal(expected,W2TAGS::parse_line(w2tg,true).join)
  end

end