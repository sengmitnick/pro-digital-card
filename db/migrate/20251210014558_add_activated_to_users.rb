class AddActivatedToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :activated, :boolean, default: false, null: false
  end
end
