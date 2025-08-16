class DonutLog < ApplicationRecord
  validates :ate_at, must_be: {
    before: :now,
    time: true,
    rule_name: :ate_in_past,
    message: "must be in the past"
  }

  validates :user_id, must_be: {
    greater_than: 0,
    rule_name: :user_id_present
  }

  validates :amount, must_be: {
    greater_than: 0,
    rule_name: :amount_min
  }

  validates :amount, must_be: {
    less_or_equal_to: 12,
    rule_name: :amount_max
  }

  validates :donut_type, must_be: {
    one_of: %w[plain glazed filled hole cake fritter],
    rule_name: :donut_type_valid
  }

  validates :flavor, must_be: {
    one_of: %w[plain chocolate strawberry blueberry],
    when: {
      donut_type: %w[plain glazed filled hole cake]
    },
    rule_name: :donut_flavor_valid
  }

  validates :flavor, must_be: {
    one_of: %w[cinnamon apple],
    when: {
      donut_type: %w[fritter] 
    },
    rule_name: :fritter_flavor_valid
  }

  validates :glaze, must_be: {
    one_of: %w[plain chocolate strawberry maple],
    when: {
      donut_type: %w[plain glazed filled hole cake]
    },
    rule_name: :donut_glaze_valid,
    allow_blank: true
  }

  validates :glaze, must_be: {
    one_of: %w[plain],
    when: {
      donut_type: %w[fritter]
    },
    rule_name: :fritter_glaze_valid,
    allow_blank: true
  }

  validates :filling, must_be: {
    one_of: %w[vanilla-pudding vanilla-cream chocolate-pudding raspberry blueberry apple],
    when: {
      donut_type: %w[filled]
    },
    rule_name: :filling_valid,
    allow_blank: true
  }

  validates :filling, must_be: {
    blank: true,
    when: {
      donut_type: %w[plain glazed hole cake fritter]
    },
    rule_name: :unfilled_not_filled
  }
end
