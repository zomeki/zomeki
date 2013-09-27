# encoding: utf-8
class GpCategory::Piece::Doc < Cms::Piece
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'published_at_desc'], ['公開日（昇順）', 'published_at_asc'], ['ランダム', 'random']]
  LAYER_OPTIONS = [['下層のカテゴリすべて', 'descendants'], ['該当カテゴリのみ', 'self']]
  PAGE_FILTER_OPTIONS = [['絞り込む', 'filter'], ['絞り込まない', 'through']]

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

  def doc_style
    setting_value(:doc_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def docs_order
    setting_value(:docs_order).to_s
  end

  def page_filter
    setting_value(:page_filter).to_s
  end

  def more_link_body
    setting_value(:more_link_body).to_s
  end

  def more_link_url
    setting_value(:more_link_url).to_s
  end

  def content
    GpCategory::Content::CategoryType.find(super)
  end

  def categories
    if category_sets.empty?
      content.category_types.inject([]) {|result, ct|
        result | ct.root_categories.inject([]) {|r, c| r | c.descendants }
      }
    else
      category_sets.map {|cs|
        unless cs[:category]
          cs[:category_type].root_categories.inject([]) {|r, c| r | c.descendants }
        else
          if cs[:layer] == 'descendants'
            cs[:category].descendants
          else
            cs[:category]
          end
        end
      }.flatten.uniq
    end
  end

  def category_sets
    value = YAML.load(setting_value(:category_sets).to_s)
    return [] unless value.is_a?(Array)
    value.map {|v|
      next nil if (v[:category_type] = GpCategory::CategoryType.find_by_id(v[:category_type_id])).nil?
      next nil if v[:category_id].nonzero? && (v[:category] = GpCategory::Category.find_by_id(v[:category_id])).nil?
      next v
    }.compact.sort do |a, b|
      next a[:category_type].unique_sort_key <=> b[:category_type].unique_sort_key if a[:category].nil? && b[:category].nil?
      next a[:category_type].unique_sort_key <=> b[:category].unique_sort_key if a[:category].nil?
      next a[:category].unique_sort_key <=> b[:category_type].unique_sort_key if b[:category].nil?
      a[:category].unique_sort_key <=> b[:category].unique_sort_key
    end
  end

  def new_category_set
    {category_type_id: nil, category_id: nil, layer: LAYER_OPTIONS.first.last}
  end

  def gp_article_content_docs
    value = YAML.load(setting_value(:gp_article_content_doc_ids).to_s)
    return [] unless value.is_a?(Array)
    value.map{|v| GpArticle::Content::Doc.find_by_id(v) }.compact
  end

  private

  def set_default_settings
    settings = self.in_settings

    settings['date_style'] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?
    settings['docs_order'] = DOCS_ORDER_OPTIONS.first.last if setting_value(:docs_order).nil?
    settings['page_filter'] = PAGE_FILTER_OPTIONS.first.last if setting_value(:page_filter).nil?

    self.in_settings = settings
  end
end
