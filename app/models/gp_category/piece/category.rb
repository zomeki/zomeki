class GpCategory::Piece::Category < Cms::Piece
  NUM_DOCS_VISIBILITY_OPTIONS = [['表示する', 'visible'], ['表示しない', 'hidden']]
  PAGE_FILTER_OPTIONS = [['絞り込む', 'filter'], ['絞り込まない', 'through']]

  default_scope where(model: 'GpCategory::Category')

  after_initialize :set_default_settings

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

  def num_docs_visibility_text
    NUM_DOCS_VISIBILITY_OPTIONS.detect{|o| o.last == setting_value(:num_docs_visibility) }.try(:first).to_s
  end

  def page_filter_text
    PAGE_FILTER_OPTIONS.detect{|o| o.last == setting_value(:page_filter) }.try(:first).to_s
  end

  private

  def set_default_settings
    settings = self.in_settings

    settings['page_filter'] = PAGE_FILTER_OPTIONS.first.last if setting_value(:page_filter).nil?

    self.in_settings = settings
  end
end
