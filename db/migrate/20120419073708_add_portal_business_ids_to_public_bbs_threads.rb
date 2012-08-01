class AddPortalBusinessIdsToPublicBbsThreads < ActiveRecord::Migration
  def change
    add_column :public_bbs_threads, :portal_business_ids, :text
  end
end
