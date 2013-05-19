require 'test/unit'
require_relative '../lib/cyberdine-game'

class MyUnitTests < Test::Unit::TestCase
  
  include Runner

  def test_command_parser()
  	assert_equal(command_parser("n"), :move)
  end

end