# encoding: utf-8
class Gnav::Piece::Doc < Cms::Piece
  default_scope where(model: 'Gnav::Doc')

  validate :validate_settings

  def validate_settings
    if (lc = in_settings['list_count']).present?
      errors.add(:base, "#{self.class.human_attribute_name :list_count} #{errors.generate_message(:base, :not_a_number)}") unless lc =~ /^[0-9]+$/
    end
  end

  def list_count
    (setting_value(:list_count).presence || 1000).to_i
  end

  def content
    Gnav::Content::MenuItem.find(super)
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
    return [] unless category_type

    if (category_id = setting_value(:category_id)).present?
      category_type.categories.where(id: category_id)
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
end
