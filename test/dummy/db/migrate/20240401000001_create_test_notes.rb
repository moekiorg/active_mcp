class CreateTestNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :test_notes do |t|
      t.string :title, null: false
      t.text :content

      t.timestamps
    end
  end
end
