class AddPortalColumnsToPublicBbsResponses < ActiveRecord::Migration
  def change
    add_column :public_bbs_responses, :portal_category_ids, :text
    add_column :public_bbs_responses, :portal_group_id, :integer
  end
end
