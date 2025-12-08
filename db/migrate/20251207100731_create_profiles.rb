class CreateProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :profiles do |t|
      t.references :user
      t.string :full_name
      t.string :title
      t.string :company
      t.string :phone
      t.string :email
      t.string :location
      t.text :bio
      t.text :specializations
      t.string :avatar_url
      t.jsonb :stats
      t.string :slug

      t.index :slug, unique: true

      t.timestamps
    end
  end
end
