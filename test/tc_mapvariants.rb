require 'test_common'

# Check that maps over constant ranges aren't converted to semi-map
class LeaveMapAlone
  include Bud

  state do
    table :num, [:num]
  end

  declare
  def rules
    num <= (1..5).map{|i| [i]}
  end
end

class AllMapsAreOne
  include Bud
  
  state do
    scratch :out, [:val]
    scratch :snout, [:val]
    scratch :clout, [:val]
    scratch :inski
  end
  
  declare
  def rules
    out <= inski {|i| [i.val]}
    snout <= inski.map {|i| [i.val]}
    clout <= inski.pro {|i| [i.val]}
  end
end

class StillAnnoying
  include Bud
  
  state do
    scratch :out, [:val]
    scratch :inski
  end
  
  declare
  def rules
    j = inski
    out <= j.map {|t| [t.val]}
  end
end

class LessAnnoying < StillAnnoying
  include Bud
  
  declare 
  def rules
    temp(tmpy) <= inski
    out <= tmpy {|t| [t.val]}
  end
end

class DupTemp < StillAnnoying
  include Bud
  
  declare
  def rules
    temp(tmpy) <= inski
    temp(tmpy) <= inski
    out <= tmpy {|t| [t.val]}
  end
end

class TestJoins < Test::Unit::TestCase
  def test_leave_map_alone
    program = LeaveMapAlone.new
    program.tick
    assert_equal([1,2,3,4,5], program.num.to_a.sort.flatten)
  end
  def test_all_maps
    p = AllMapsAreOne.new
    p.inski <+ [[1,1],
                [2,2],
                [3,3]]
    p.tick
    assert_equal(3, p.out.length)
    assert_equal(p.out.inspected, p.snout.inspected)
    assert_equal(p.out.inspected, p.clout.inspected)
  end
  def test_still_annoying
    p = StillAnnoying.new
    assert_raise(LocalJumpError, p.tick)
  end
  def test_less_annoying
    p = LessAnnoying.new
    p.inski <+ [[1,1],
                [2,2],
                [3,3]]
    p.tick
    assert_equal(3, p.out.length)
    assert_equal([[1], [2], [3]], p.out.map{|o| [o.val]}.sort)
  end
  def test_dup_tmp
    assert_raise(Bud::BudError) {DupTemp.new}
  end
end
