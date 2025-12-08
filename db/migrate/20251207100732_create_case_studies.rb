class CreateCaseStudies < ActiveRecord::Migration[7.2]
  def change
    create_table :case_studies do |t|
      t.references :profile
      t.string :title
      t.string :category
      t.string :date
      t.text :description
      t.integer :position


      t.timestamps
    end
  end
end
