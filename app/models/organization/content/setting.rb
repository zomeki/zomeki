class Organization::Content::Setting < Cms::ContentSetting
  set_config :article_relation, :name => '汎用記事URL保持許可',
    options: Organization::Content::Group::ARTICLE_RELATION_OPTIONS,
    form_type: :radio_buttons
  set_config :doc_style, name: "#{GpArticle::Doc.model_name.human}表示形式",
    form_type: :text_area
  set_config :date_style, name: "#{GpArticle::Doc.model_name.human}日付形式",
    comment: I18n.t('comments.date_style').html_safe
  set_config :time_style, name: "#{GpArticle::Doc.model_name.human}時間形式",
    comment: I18n.t('comments.time_style').html_safe
  set_config :num_docs, name: "#{GpArticle::Doc.model_name.human}表示件数"
  set_config :gp_category_content_category_type_id, name: '汎用カテゴリタイプ',
    options: lambda { GpCategory::Content::CategoryType.where(site_id: Core.site.id).map {|ct| [ct.name, ct.id] } }

  validate :validate_value

  def upper_text
    case name
    when 'doc_style'
      ActionController::Base.helpers.link_to_function '置き換えテキストを確認する', "$('#doc_style_tags').dialog({width: 400})"
    end
  end

  def lower_text
    case name
    when 'doc_style'
      ActionController::Base.helpers.render file: 'app/views/gp_article/admin/shared/_doc_style_tags.html.erb'
    end
  end

  private

  def validate_value
    case name
    when 'num_docs'
      errors.add :value, :not_a_number unless value =~ /^\d+$/
    end
  end
end
