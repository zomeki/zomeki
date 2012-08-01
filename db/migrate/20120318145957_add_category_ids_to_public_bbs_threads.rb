class AddCategoryIdsToPublicBbsThreads < ActiveRecord::Migration
  def change
    add_column :public_bbs_threads, :category_ids, :text
  end
end
