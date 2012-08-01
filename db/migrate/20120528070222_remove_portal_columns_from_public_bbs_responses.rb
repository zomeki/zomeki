class RemovePortalColumnsFromPublicBbsResponses < ActiveRecord::Migration
  def up
    remove_column :public_bbs_responses, :portal_area_ids
    remove_column :public_bbs_responses, :portal_attribute_ids
    remove_column :public_bbs_responses, :portal_business_ids
    remove_column :public_bbs_responses, :portal_category_ids
    remove_column :public_bbs_responses, :portal_group_id
    remove_column :public_bbs_responses, :category_ids
  end

  def down
    add_column :public_bbs_responses, :category_ids, :text
    add_column :public_bbs_responses, :portal_group_id, :integer
    add_column :public_bbs_responses, :portal_category_ids, :text
    add_column :public_bbs_responses, :portal_business_ids, :text
    add_column :public_bbs_responses, :portal_attribute_ids, :text
    add_column :public_bbs_responses, :portal_area_ids, :text
  end
end
