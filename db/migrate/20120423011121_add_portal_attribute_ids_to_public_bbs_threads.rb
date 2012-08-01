class AddPortalAttributeIdsToPublicBbsThreads < ActiveRecord::Migration
  def change
    add_column :public_bbs_threads, :portal_attribute_ids, :text
  end
end
