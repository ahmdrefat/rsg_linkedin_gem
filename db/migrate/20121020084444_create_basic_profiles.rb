class CreateBasicProfiles < ActiveRecord::Migration
  def change
    create_table :basic_profiles do |t|
      t.string :first_name
      t.string :last_name
      t.string :maiden_name
      t.string :formatted_name
      t.string :headline
      t.string :location
      t.string :industry
      t.string :summary
      t.string :specialties
      t.string :picture_url
      t.string :public_profile_url
      t.integer :user_id

      t.timestamps
    end
  end
end
