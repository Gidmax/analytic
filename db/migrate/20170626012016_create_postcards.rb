class CreatePostcards < ActiveRecord::Migration[5.0]
  def change
    create_table :postcards do |t|
      t.string :title
      t.text :desc
      t.string :ix
      t.text :src

      t.timestamps
    end
  end
end
