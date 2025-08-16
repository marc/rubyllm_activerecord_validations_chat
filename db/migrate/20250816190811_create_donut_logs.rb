class CreateDonutLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :donut_logs do |t|
      t.integer :user_id
      t.decimal :amount
      t.datetime :ate_at
      t.string :donut_type
      t.string :flavor
      t.string :glaze
      t.string :filling
      t.string :location
      t.string :note

      t.timestamps
    end
  end
end
