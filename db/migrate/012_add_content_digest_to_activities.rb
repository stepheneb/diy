class AddContentDigestToActivities < ActiveRecord::Migration
  def self.up
    add_column "activities", :content_digest, :string
  end

  def self.down
    remove_column "activities", :content_digest
  end
end
