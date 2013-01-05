class AddExtraValueToCmsContentSettings < ActiveRecord::Migration
  def change
    add_column :cms_content_settings, :extra_value, :text
  end
end
