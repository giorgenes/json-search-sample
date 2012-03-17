require 'example'

require 'test/unit'

class MyProblemTest < Test::Unit::TestCase
  def test_it_works
    p = MyProblem.new
    assert_not_nil p.matches?('124A')    
    assert_nil p.matches?('aasd')
  end
end
