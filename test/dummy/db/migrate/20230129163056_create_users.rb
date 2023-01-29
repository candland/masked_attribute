class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.integer :role_mask, null: false, default: 0

      t.timestamps
    end
  end
end
