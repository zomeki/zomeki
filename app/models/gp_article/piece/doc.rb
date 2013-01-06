# encoding: utf-8
class GpArticle::Piece::Doc < Cms::Piece
  validate :validate_settings

  def validate_settings
    if (ct_id = in_settings['category_type_id']).present?
      errors.add(:base, "#{self.class.human_attribute_name :category_type_id} #{errors.generate_message(:base, :not_a_number)}") unless ct_id =~ /^[0-9]+$/
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
end
