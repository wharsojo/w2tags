module HotTest  
  def test_hots
easy_test(<<W2TAGS____________,<<EXPECTED__________)
!hot!feature
-code#item1{options="rain"}= manstabs
W2TAGS____________
<span id="item1" options="rain"><%= manstabs %></span>
EXPECTED__________
  end
end
