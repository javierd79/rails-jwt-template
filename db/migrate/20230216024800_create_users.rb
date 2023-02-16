class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :avatar
      t.string :name
      t.string :username
      t.string :email
      t.string :password_digest
      t.datetime :deleted_at # Add a column to store whether the record is deleted or not

      t.timestamps

      add_index :users, :email, unique: true # Add an index on the email column for faster lookups
      add_index :users, :username, unique: true # Add an index on the username column for faster lookups
      add_index :users, :deleted_at # Add an index on the deleted_at column for faster lookups
    end
  end
end