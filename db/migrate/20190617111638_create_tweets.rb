class CreateTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :tweets do |t|
      t.integer :user_id
      t.string :comment
      t.boolean :display_flg, null: false, default: true

      t.timestamps
    end
  end
end
