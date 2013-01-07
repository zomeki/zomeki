# encoding: utf-8
class GpArticle::Piece::Doc < Cms::Piece
  default_scope where(model: 'GpArticle::Doc')

  validate :validate_settings

  def validate_settings
    if (lc = in_settings['list_count']).present?
      errors.add(:base, "#{self.class.human_attribute_name :list_count} #{errors.generate_message(:base, :not_a_number)}") unless lc =~ /^[0-9]+$/
    end
  end

  def content
    GpArticle::Content::Doc.find(super.id)
  end

  def category_types
    content.category_types
  end

  def category_types_for_option
    category_types.map {|ct| [ct.title, ct.id] }
  end

  def category_type
    return nil unless category_types.respond_to?(:find_by_id)
    category_types.find_by_id(setting_value(:category_type_id))
  end

  def categories
    category_type.try(:categories) || []
  end

  def categories_for_option
    category_type.try(:categories_for_option) || []
  end

  def category
    return nil unless categories.respond_to?(:find_by_id)
    categories.find_by_id(setting_value(:category_id))
  end

  def list_count
    (setting_value(:list_count).presence || 100).to_i
  end
end
