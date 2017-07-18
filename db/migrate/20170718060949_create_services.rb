class CreateServices < ActiveRecord::Migration[5.0]
  def change
    create_table :services do |t|
      t.string :account
      t.string :author
      t.string :title
      t.integer :access
      t.timestamps
    end
  end
end
