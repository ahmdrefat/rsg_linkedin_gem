class CreateEducations < ActiveRecord::Migration
  def change
    create_table :educations do |t|
      t.string :school_name
      t.string :field_of_study
      t.date :start_date
      t.date :end_date
      t.string :degree
      t.string :activities
      t.string :notes
      t.integer :full_profile_id

      t.timestamps
    end
  end
end
