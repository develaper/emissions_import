require 'test_helper'

class EmissionTest < ActiveSupport::TestCase
  def setup
    @valid_emission = emissions(:one)
  end

  test "should be valid" do
    assert @valid_emission.valid?
  end
end
