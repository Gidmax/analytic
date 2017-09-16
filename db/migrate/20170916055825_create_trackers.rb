class CreateTrackers < ActiveRecord::Migration[5.0]
  def change
    create_table :trackers do |t|
      t.string :code
      t.text :desc
      t.string :user_id
      t.integer :count_of_access

      t.timestamps
    end
  end
end
