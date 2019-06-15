class SorceryCore < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :crypted_password, null: false

      t.string :name, null: false
      t.boolean :admin_flg, null: false, default: false

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :name, unique: true
  end
end
