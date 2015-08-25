class AddCreatorGroupRelationSettingToToolConvertSettings < ActiveRecord::Migration
  def change
    add_column :tool_convert_settings, :creator_group_relation_type, :integer, :after => :creator_group_from_url_regexp
    add_column :tool_convert_settings, :creator_group_url_relations, :text, :after => :creator_group_relation_type
  end
end
