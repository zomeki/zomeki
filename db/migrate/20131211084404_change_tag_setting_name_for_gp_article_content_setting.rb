class ChangeTagSettingNameForGpArticleContentSetting < ActiveRecord::Migration
  def change
    GpArticle::Content::Setting.where(name: 'tag_content_tag_id').each do |item|
      tag_id = item.value
      if tag_id.present?
        item.value = 'enabled'
        item.extra_values = { tag_content_tag_id: tag_id.to_i }.with_indifferent_access
      else
        item.value = 'disabled'
      end
      item.name = 'tag_relation'
      item.save
    end
  end
end
