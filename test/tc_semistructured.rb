require 'test_common'

class Semi
    include Bud
    
    state do
      table :stuff
      table :bigstuff, stuff.schema + [:extra1] + [:extra2]
    end
    
    def bootstrap
      bigstuff << [1,2,3,4]
      bigstuff << [2, 'check', {:key => 'out'}, ['me', ['and', 'my'], 'nested'], 'ways']
    end
    
    declare 
    def whynot
      stuff <= bigstuff
    end
end

class TestSemi < Test::Unit::TestCase
  def test_semi
    p = Semi.new
    assert_nothing_raised(RuntimeError) { p.tick }
    # if we kept all the extra stuff, we can "walk" the struct to find things
    assert(p.stuff.first.length > p.stuff.schema.length)
    assert_equal([1,2, [3, 4]], p.stuff.first)
    assert_equal('check', (p.stuff.first(2)[1][1]))
    assert_equal('out', (p.stuff.first(2)[1][-1][0][:key]))
    assert_equal('me', (p.stuff.first(2)[1][-1][1][0]))
    assert_equal('and', (p.stuff.first(2)[1][-1][1][1][0]))
    assert_equal('my', (p.stuff.first(2)[1][-1][1][1][1]))
    assert_equal('nested', (p.stuff.first(2)[1][-1][1][2]))
    assert_equal(['ways'], (p.stuff.first(2)[1][-1][2]))
  end
end