class AddPortalCategoryIdsToPublicBbsThreads < ActiveRecord::Migration
  def change
    add_column :public_bbs_threads, :portal_category_ids, :text
  end
end
