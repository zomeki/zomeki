class AddPortalGroupIdToPublicBbsThreads < ActiveRecord::Migration
  def change
    add_column :public_bbs_threads, :portal_group_id, :integer
  end
end
