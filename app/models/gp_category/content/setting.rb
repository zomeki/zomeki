# encoding: utf-8
class GpCategory::Content::Setting < Cms::ContentSetting
  set_config :group_category_type_name, :name => "組織用#{GpCategory::CategoryType.human_attribute_name :name}",
    :comment => '初期値 ： groups'
  set_config :list_style, :name => "#{GpArticle::Doc.model_name.human}表示形式",
    :form_type => :text_area, :comment_upper => 'doc_style_tags'
  set_config :date_style, :name => "#{GpArticle::Doc.model_name.human}日付形式",
    :comment => I18n.t('comments.date_style').html_safe
  set_config :time_style, :name => "#{GpArticle::Doc.model_name.human}時間形式",
    :comment => I18n.t('comments.time_style').html_safe
  set_config :category_type_style, :name => "#{GpCategory::CategoryType.model_name.human}表示形式",
    :options => GpCategory::Content::CategoryType::CATEGORY_TYPE_STYLE_OPTIONS
  set_config :category_style, :name => "#{GpCategory::Category.model_name.human}表示形式",
    :options => GpCategory::Content::CategoryType::CATEGORY_STYLE_OPTIONS
  set_config :doc_style, :name => '新着記事一覧表示形式',
    :options => GpCategory::Content::CategoryType::DOC_STYLE_OPTIONS
  set_config :index_template_id, :name => 'index設定',
    :options => lambda {->(content=nil) do
        if content
          GpCategory::Content::CategoryType.find(content).templates.map{|t| [t.title, t.id] }
        else
          []
        end
      end}
  set_config :feed, :name => "フィード",
    :options => GpCategory::Content::CategoryType::FEED_DISPLAY_OPTIONS,
    :form_type => :radio_buttons

  after_initialize :set_defaults

  def upper_text
  end

  def lower_text
  end

  private

  def set_defaults
    case name
    when 'feed'
      self.value = 'enabled' if value.blank?
      self.extra_values = { feed_docs_number: '10' } if extra_values.blank?
    end
  end
end
