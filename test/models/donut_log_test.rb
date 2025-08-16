require "test_helper"

class DonutLogTest < ActiveSupport::TestCase
  def setup
    @valid_attributes = {
      user_id: 1,
      amount: 2.50,
      ate_at: 1.day.ago,
      donut_type: "glazed",
      flavor: "plain"
    }
  end

  test "should create a valid donut log" do
    donut_log = DonutLog.new(@valid_attributes)
    assert donut_log.valid?
  end

  # # ate_in_past rule tests
  test "ate_in_past rule - should be valid when ate_at is in the past" do
    donut_log = DonutLog.new(@valid_attributes.merge(ate_at: 1.day.ago))
    assert donut_log.valid?
  end

  test "ate_in_past rule - should be invalid when ate_at is in the future" do
    donut_log = DonutLog.new(@valid_attributes.merge(ate_at: 1.day.from_now))
    assert_not donut_log.valid?
    assert_includes donut_log.errors[:ate_at], "must be in the past"
  end

  test "ate_in_past rule - should be valid when ate_at is now because there is a +60 leniency built into the gem" do
    # Time.now + 60  # be lenient on now for server clocks
    donut_log = DonutLog.new(@valid_attributes.merge(ate_at: Time.now ))
    assert donut_log.valid?
  end

  test "ate_in_past rule - should be valid when ate_at is now + 59 seconds because there is a +60 leniency built into the gem" do
    # Time.now + 60  # be lenient on now for server clocks
    donut_log = DonutLog.new(@valid_attributes.merge(ate_at: Time.now + 59.seconds))
    assert donut_log.valid?
  end

  test "ate_in_past rule - should be invalid valid when ate_at is now+61" do
    donut_log = DonutLog.new(@valid_attributes.merge(ate_at: Time.now + 61.seconds))
    assert_equal false, donut_log.valid?
  end

  test "ate_in_past rule - should be invalid valid when ate_at is now+120" do
    donut_log = DonutLog.new(@valid_attributes.merge(ate_at: Time.now + 120.seconds))
    assert_equal false, donut_log.valid?
  end

  # user_id_present rule tests
  test "user_id_present rule - should be valid when user_id is greater than 0" do
    donut_log = DonutLog.new(@valid_attributes.merge(user_id: 1))
    assert donut_log.valid?
  end

  test "user_id_present rule - should be invalid when user_id is 0" do
    donut_log = DonutLog.new(@valid_attributes.merge(user_id: 0))
    assert_not donut_log.valid?
    assert_includes donut_log.errors[:user_id], "must be greater than 0."
  end

  test "user_id_present rule - should be invalid when user_id is negative" do
    donut_log = DonutLog.new(@valid_attributes.merge(user_id: -1))
    assert_not donut_log.valid?
  end

  test "user_id_present rule - should be invalid when user_id is nil" do
    donut_log = DonutLog.new(@valid_attributes.except(:user_id))
    assert_not donut_log.valid?
  end

  # amount_min rule tests
  test "amount_min rule - should be valid when amount is greater than 0" do
    donut_log = DonutLog.new(@valid_attributes.merge(amount: 0.01))
    assert donut_log.valid?
  end

  test "amount_min rule - should be invalid when amount is 0" do
    donut_log = DonutLog.new(@valid_attributes.merge(amount: 0))
    assert_not donut_log.valid?
    assert_includes donut_log.errors[:amount], "must be greater than 0."
  end

  test "amount_min rule - should be invalid when amount is negative" do
    donut_log = DonutLog.new(@valid_attributes.merge(amount: -1.50))
    assert_not donut_log.valid?
  end

  test "amount_min rule - should be invalid when amount is nil" do
    donut_log = DonutLog.new(@valid_attributes.except(:amount))
    assert_not donut_log.valid?
  end

  # amount_max rule tests
  test "amount_max rule - should be valid when amount is less than or equal to 12" do
    donut_log = DonutLog.new(@valid_attributes.merge(amount: 12.00))
    assert donut_log.valid?
  end

  test "amount_max rule - should be valid when amount is less than 12" do
    donut_log = DonutLog.new(@valid_attributes.merge(amount: 11.99))
    assert donut_log.valid?
  end

  test "amount_max rule - should be invalid when amount is greater than 12" do
    donut_log = DonutLog.new(@valid_attributes.merge(amount: 12.01))
    assert_not donut_log.valid?
    assert_includes donut_log.errors[:amount], "must be less or equal to 12."
  end

  # donut_type_valid rule tests
  test "donut_type_valid rule - should be valid with allowed donut types" do
    %w[plain glazed filled hole cake].each do |type|
      donut_log = DonutLog.new(@valid_attributes.merge(donut_type: type))
      donut_log.valid?
      assert donut_log.valid?, "#{type} should be valid"
    end
    %w[fritter].each do |type|
      donut_log = DonutLog.new(@valid_attributes.merge(donut_type: type, flavor: "apple"))
      donut_log.valid?
      assert donut_log.valid?, "#{type} should be valid"
    end
  end

  test "donut_type_valid rule - should be invalid with disallowed donut types" do
    donut_log = DonutLog.new(@valid_attributes.merge(donut_type: "invalid_type"))
    assert_not donut_log.valid?
    assert_includes donut_log.errors[:donut_type], ": 'invalid_type' is not a valid value. Valid values: plain, glazed, filled, hole, cake, fritter."
  end

  test "donut_type_valid rule - should be invalid when donut_type is nil" do
    donut_log = DonutLog.new(@valid_attributes.except(:donut_type))
    assert_not donut_log.valid?
  end

  # donut_flavor_valid rule tests
  test "donut_flavor_valid rule - should be valid with allowed flavors for regular donuts" do
    %w[plain chocolate strawberry blueberry].each do |flavor|
      donut_log = DonutLog.new(@valid_attributes.merge(
        donut_type: "glazed",
        flavor: flavor
      ))
      assert donut_log.valid?, "#{flavor} should be valid for glazed donut"
    end
  end

  test "donut_flavor_valid rule - should be invalid with disallowed flavors for regular donuts" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "glazed",
      flavor: "cinnamon"
    ))
    assert_not donut_log.valid?
  end

  test "donut_flavor_valid rule - should be invalid when flavor is nil for regular donuts" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "glazed"
    ).except(:flavor))
    assert_not donut_log.valid?
  end

  # fritter_flavor_valid rule tests
  test "fritter_flavor_valid rule - should be valid with allowed flavors for fritters" do
    %w[cinnamon apple].each do |flavor|
      donut_log = DonutLog.new(@valid_attributes.merge(
        donut_type: "fritter",
        flavor: flavor
      ))
      assert donut_log.valid?, "#{flavor} should be valid for fritter"
    end
  end

  test "fritter_flavor_valid rule - should be invalid with disallowed flavors for fritters" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "fritter",
      flavor: "plain"
    ))
    assert_not donut_log.valid?
  end

  # donut_glaze_valid rule tests
  test "donut_glaze_valid rule - should be valid with allowed glazes for regular donuts" do
    %w[plain chocolate strawberry maple].each do |glaze|
      donut_log = DonutLog.new(@valid_attributes.merge(
        donut_type: "glazed",
        glaze: glaze
      ))
      assert donut_log.valid?, "#{glaze} should be valid glaze"
    end
  end

  test "donut_glaze_valid rule - should be valid when glaze is blank" do
    donut_log = DonutLog.new(@valid_attributes.merge(glaze: ""))
    assert donut_log.valid?
  end

  test "donut_glaze_valid rule - should be valid when glaze is nil" do
    donut_log = DonutLog.new(@valid_attributes.merge(glaze: nil))
    assert donut_log.valid?
  end

  test "donut_glaze_valid rule - should be invalid with disallowed glazes" do
    donut_log = DonutLog.new(@valid_attributes.merge(glaze: "invalid_glaze"))
    assert_not donut_log.valid?
  end

  # fritter_glaze_valid rule tests
  test "fritter_glaze_valid rule - should be valid with plain glaze for fritters" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "fritter",
      flavor: "apple",
      glaze: "plain"
    ))
    assert donut_log.valid?
  end

  test "fritter_glaze_valid rule - should be valid when glaze is blank for fritters" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "fritter",
      flavor: "apple",
      glaze: ""
    ))
    assert donut_log.valid?
  end

  test "fritter_glaze_valid rule - should be valid when glaze is nil for fritters" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "fritter",
      flavor: "apple"
    ).except(:glaze))
    assert donut_log.valid?
  end

  test "fritter_glaze_valid rule - should be invalid with non-plain glaze for fritters" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "fritter",
      flavor: "apple",
      glaze: "chocolate"
    ))
    assert_not donut_log.valid?
  end

  # filling_valid rule tests
  test "filling_valid rule - should be valid with allowed fillings for filled donuts" do
    %w[vanilla-pudding vanilla-cream chocolate-pudding raspberry blueberry apple].each do |filling|
      donut_log = DonutLog.new(@valid_attributes.merge(
        donut_type: "filled",
        filling: filling
      ))
      assert donut_log.valid?, "#{filling} should be valid filling"
    end
  end

  test "filling_valid rule - should be valid when filling is blank for non-filled donuts" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "glazed",
      filling: ""
    ))
    assert donut_log.valid?
  end

  test "filling_valid rule - should be valid when filling is nil for non-filled donuts" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "glazed"
    ).except(:filling))
    assert donut_log.valid?
  end

  test "filling_valid rule - should be invalid with disallowed fillings for filled donuts" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "filled",
      filling: "invalid_filling"
    ))
    assert_not donut_log.valid?
  end

  # unfilled_not_filled rule tests
  test "unfilled_not_filled rule - should be valid when donut_type is not 'filled' and filling is blank" do
    %w[plain glazed hole cake].each do |type|
      donut_log = DonutLog.new(@valid_attributes.merge(
        donut_type: type,
        filling: ""
      ))
      assert donut_log.valid?, "#{type} should be valid with blank filling"
    end
    
    # Test fritter separately with correct flavor
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "fritter",
      flavor: "apple",
      filling: ""
    ))
    assert donut_log.valid?, "fritter should be valid with blank filling"
  end

  test "unfilled_not_filled rule - should be valid when donut_type is not 'filled' and filling is nil" do
    %w[plain glazed hole cake].each do |type|
      donut_log = DonutLog.new(@valid_attributes.merge(
        donut_type: type
      ).except(:filling))
      assert donut_log.valid?, "#{type} should be valid with nil filling"
    end
    
    # Test fritter separately with correct flavor
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "fritter",
      flavor: "apple"
    ).except(:filling))
    assert donut_log.valid?, "fritter should be valid with nil filling"
  end

  test "unfilled_not_filled rule - should be invalid when donut_type is not 'filled' but filling is present" do
    %w[plain glazed hole cake fritter].each do |type|
      donut_log = DonutLog.new(@valid_attributes.merge(
        donut_type: type,
        filling: "vanilla-cream"
      ))
      assert_not donut_log.valid?, "#{type} should be invalid with filling present"
      assert_includes donut_log.errors[:filling], "must be blank when donut_type = #{type}."
    end
  end

  test "unfilled_not_filled rule - should be valid when donut_type is 'filled' and filling is present" do
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "filled",
      filling: "vanilla-cream"
    ))
    assert donut_log.valid?
  end

  # Edge cases and integration tests
  test "integration - should handle complex validation scenarios" do
    # Valid filled donut with all attributes
    donut_log = DonutLog.new(
      user_id: 1,
      amount: 3.50,
      ate_at: 1.day.ago,
      donut_type: "filled",
      flavor: "chocolate",
      glaze: "chocolate",
      filling: "vanilla-cream",
      location: "Local Bakery",
      note: "Delicious!"
    )
    assert donut_log.valid?
  end

  test "integration - should handle minimum valid donut" do
    # Minimal valid donut with only required fields
    donut_log = DonutLog.new(
      user_id: 1,
      amount: 0.01,
      ate_at: 1.day.ago,
      donut_type: "plain",
      flavor: "plain"
    )
    assert donut_log.valid?
  end

  test "integration - should handle maximum valid amount" do
    donut_log = DonutLog.new(@valid_attributes.merge(amount: 12.00))
    assert donut_log.valid?
  end

  # Additional edge case tests
  test "edge case - should handle boundary amount values" do
    # Test exact boundary values
    donut_log = DonutLog.new(@valid_attributes.merge(amount: 0.01))
    assert donut_log.valid?, "0.01 should be valid (minimum)"

    donut_log = DonutLog.new(@valid_attributes.merge(amount: 12.00))
    assert donut_log.valid?, "12.00 should be valid (maximum)"
  end

  test "edge case - should handle all donut type combinations" do
    valid_combinations = {
      "plain" => { flavor: "plain", glaze: "plain", filling: nil },
      "glazed" => { flavor: "chocolate", glaze: "chocolate", filling: nil },
      "filled" => { flavor: "strawberry", glaze: "strawberry", filling: "vanilla-cream" },
      "hole" => { flavor: "blueberry", glaze: "maple", filling: nil },
      "cake" => { flavor: "plain", glaze: nil, filling: nil },
      "fritter" => { flavor: "apple", glaze: "plain", filling: nil }
    }

    valid_combinations.each do |type, attrs|
      donut_log = DonutLog.new(@valid_attributes.merge(donut_type: type, **attrs))
      assert donut_log.valid?, "#{type} combination should be valid"
    end
  end

  test "edge case - should validate conditional flavor logic correctly" do
    # Test that fritter can't use regular donut flavors
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "fritter",
      flavor: "chocolate"
    ))
    assert_not donut_log.valid?, "Fritter should not accept chocolate flavor"

    # Test that regular donuts can't use fritter flavors
    donut_log = DonutLog.new(@valid_attributes.merge(
      donut_type: "glazed",
      flavor: "cinnamon"
    ))
    assert_not donut_log.valid?, "Glazed donut should not accept cinnamon flavor"
  end

  test "edge case - should handle location and note as optional fields" do
    # Test with location and note
    donut_log = DonutLog.new(@valid_attributes.merge(
      location: "Local Bakery",
      note: "Delicious donut!"
    ))
    assert donut_log.valid?, "Should be valid with location and note"

    # Test without location and note
    donut_log = DonutLog.new(@valid_attributes.except(:location, :note))
    assert donut_log.valid?, "Should be valid without location and note"
  end
end
