class AddCategoryIdsToPublicBbsResponses < ActiveRecord::Migration
  def change
    add_column :public_bbs_responses, :category_ids, :text
  end
end
