class AddPortalColumns2ToPublicBbsResponses < ActiveRecord::Migration
  def change
    add_column :public_bbs_responses, :portal_business_ids, :text
    add_column :public_bbs_responses, :portal_attribute_ids, :text
    add_column :public_bbs_responses, :portal_area_ids, :text
  end
end
