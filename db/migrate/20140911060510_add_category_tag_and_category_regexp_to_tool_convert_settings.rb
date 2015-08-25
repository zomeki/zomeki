class AddCategoryTagAndCategoryRegexpToToolConvertSettings < ActiveRecord::Migration
  def change
    add_column :tool_convert_settings, :category_tag, :text, :after => :creator_group_from_url_regexp
    add_column :tool_convert_settings, :category_regexp, :text, :after => :category_tag
  end
end
