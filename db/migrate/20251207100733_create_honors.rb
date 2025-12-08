class CreateHonors < ActiveRecord::Migration[7.2]
  def change
    create_table :honors do |t|
      t.references :profile
      t.string :title
      t.string :organization
      t.string :date
      t.text :description
      t.string :icon_name


      t.timestamps
    end
  end
end
