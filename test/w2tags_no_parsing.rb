module W2tagsNoParsing  
  def test_empty
    assert_equal([], ParserTest::W2TAGS::parse_line('',true))
    assert_equal([], ParserTest::W2TAGS::parse_line("\n\n\n\n\n\n",true))
    assert_equal([], ParserTest::W2TAGS::parse_line("\n    \n    ",true))
  end
  
  def test_remark_01
easy_test(<<W2TAGS____________,<<EXPECTED__________)
-# remark only
  you will see nothing
-!
  you see this line 
  but will not parse
W2TAGS____________
  you see this line
  but will not parse
EXPECTED__________
  end
  def test_not_parse_01
easy_test(<<W2TAGS____________,<<EXPECTED__________)
-!
  how about this line
W2TAGS____________
  how about this line
EXPECTED__________
  end
  def test_not_parse_02
easy_test(<<W2TAGS____________,<<EXPECTED__________)
-! first inline
 how about this line
W2TAGS____________
 first inline
 how about this line
EXPECTED__________
  end
end
