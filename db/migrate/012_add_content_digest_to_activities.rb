class AddContentDigestToActivities < ActiveRecord::Migration
  def self.up
    add_column "#{RAILS_DATABASE_PREFIX}activities", :content_digest, :string
  end

  def self.down
    remove_column "#{RAILS_DATABASE_PREFIX}activities", :content_digest
  end
end
