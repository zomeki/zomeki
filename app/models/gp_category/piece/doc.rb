# encoding: utf-8
class GpCategory::Piece::Doc < Cms::Piece
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

  def list_style
    setting_value(:list_style) || ''
  end

  def date_style
    setting_value(:date_style) || ''
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

  private

  def set_default_settings
    settings = self.in_settings

    settings['layer'] = LAYER_OPTIONS.first.last if setting_value(:layer).nil?
    settings['list_style'] = '@title(@date @group)' if setting_value(:list_style).nil?
    settings['date_style'] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?

    self.in_settings = settings
  end
end
