class AddRegistrationMetadataToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :registration_metadata, :jsonb, default: {}, null: false
  end
end
