class CreateNotes < ActiveRecord::Migration[7.2]
  def change
    create_table :notes do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.references :user, index: true

      t.timestamps
    end
  end
end
