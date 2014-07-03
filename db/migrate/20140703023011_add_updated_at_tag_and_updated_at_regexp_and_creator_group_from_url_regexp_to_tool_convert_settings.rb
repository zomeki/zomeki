class AddUpdatedAtTagAndUpdatedAtRegexpAndCreatorGroupFromUrlRegexpToToolConvertSettings < ActiveRecord::Migration
  def change
    add_column :tool_convert_settings, :updated_at_tag, :text, :after => :body_tag
    add_column :tool_convert_settings, :updated_at_regexp, :text, :after => :updated_at_tag
    add_column :tool_convert_settings, :creator_group_from_url_regexp, :text, :after => :updated_at_regexp
  end
end
