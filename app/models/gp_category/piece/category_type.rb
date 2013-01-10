# encoding: utf-8
class GpCategory::Piece::CategoryType < Cms::Piece
  LAYER_OPTIONS = [['下層のカテゴリすべて', 'descendants'], ['該当カテゴリのみ', 'self']]

  default_scope where(model: 'GpCategory::CategoryType')

  def layer
    setting_value(:layer).presence || LAYER_OPTIONS.first.last
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
    return [] unless category_type

    if (category_id = setting_value(:category_id)).present?
      if layer == 'descendants'
        category_type.categories.find_by_id(category_id).try(:descendants) || []
      else
        category_type.categories.where(id: category_id)
      end
    else
      category_type.categories
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

  def categorize_docs(docs)
    return docs unless category_type

    docs.select do |doc|
      category_ids = (doc.respond_to?(:category_ids) ? doc.category_ids : doc.categories.map(&:id))
      !(category_ids & self.categories.map(&:id)).empty?
    end
  end
end
