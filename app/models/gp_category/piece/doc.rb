# encoding: utf-8
class GpCategory::Piece::Doc < Cms::Piece
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'published_at_desc'], ['公開日（昇順）', 'published_at_asc'], ['ランダム', 'random']]
  LAYER_OPTIONS = [['下層のカテゴリすべて', 'descendants'], ['該当カテゴリのみ', 'self']]

  default_scope where(model: 'GpCategory::Doc')

  after_initialize :set_default_settings

  validate :validate_settings

  def validate_settings
    if (lc = in_settings['list_count']).present?
      errors.add(:base, "#{self.class.human_attribute_name :list_count} #{errors.generate_message(:base, :not_a_number)}") unless lc =~ /^[0-9]+$/
    end
  end

  def list_count
    (setting_value(:list_count).presence || 1000).to_i
  end

  def layer
    setting_value(:layer).presence || LAYER_OPTIONS.first.last
  end

  def doc_style
    setting_value(:doc_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def content
    GpCategory::Content::CategoryType.find(super)
  end

  def category_types
    content.category_types
  end

  def category_types_for_option
    category_types.map {|ct| [ct.title, ct.id] }
  end

  def category_type
    category_types.find_by_id(setting_value(:category_type_id))
  end

  def categories
    unless category_type
      return category_types.inject([]) {|result, ct|
                 result | ct.root_categories.inject([]) {|r, c| r | c.descendants }
               }
    end

    if (category_id = setting_value(:category_id)).present?
      if layer == 'descendants'
        category_type.categories.find_by_id(category_id).try(:descendants) || []
      else
        category_type.categories.where(id: category_id)
      end
    else
      category_type.root_categories.inject([]) {|r, c| r | c.descendants }
    end
  end

  def category
    return nil if categories.empty?

    if categories.respond_to?(:find_by_id)
      categories.find_by_id(setting_value(:category_id))
    else
      categories.detect {|c| c.id.to_s == setting_value(:category_id) }
    end
  end

  def category_sets
    value = YAML.load(setting_value(:category_sets).to_s)
    return [] unless value.is_a?(Array)
    value.map{|v|
      v[:category] = GpCategory::Category.find_by_id(v[:category_id])
      v[:category] ? v : nil
    }.compact.sort {|a, b| a[:category].unique_sort_key <=> b[:category].unique_sort_key }
  end

  def new_category_set
    {category: nil, layer: LAYER_OPTIONS.first.last}
  end

  def gp_article_content_docs
    value = YAML.load(setting_value(:gp_article_content_doc_ids).to_s)
    return [] unless value.is_a?(Array)
    value.map{|v| GpArticle::Content::Doc.find_by_id(v) }.compact
  end

  private

  def set_default_settings
    settings = self.in_settings

    settings['layer'] = LAYER_OPTIONS.first.last if setting_value(:layer).nil?
    settings['date_style'] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?
    settings['docs_order'] = DOCS_ORDER_OPTIONS.first.last if setting_value(:docs_order).nil?

    self.in_settings = settings
  end
end
