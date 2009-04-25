module W2tagsForm
  def test_form_01
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%form
  %button:submit/
W2TAGS____________
<form>
  <button name="submit"/>
</form>
EXPECTED__________
  end
  def test_form_02
easy_test(<<W2TAGS____________,<<EXPECTED__________)
%form
  :submit{type="button"}
W2TAGS____________
<form>
  <input name="submit" type="button" />
</form>
EXPECTED__________
  end
  def test_form_03
easy_test(<<W2TAGS____________,<<EXPECTED__________)
W2TAGS____________
EXPECTED__________
  end
  def test_form_04
easy_test(<<W2TAGS____________,<<EXPECTED__________)
W2TAGS____________
EXPECTED__________
  end
end
