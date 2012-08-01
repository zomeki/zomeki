class AddPortalAreaIdsToPublicBbsThreads < ActiveRecord::Migration
  def change
    add_column :public_bbs_threads, :portal_area_ids, :text
  end
end
