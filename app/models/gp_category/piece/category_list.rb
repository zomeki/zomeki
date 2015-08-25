# encoding: utf-8
class GpCategory::Piece::CategoryList < Cms::Piece
  LAYER_OPTIONS = [['下層のカテゴリすべて', 'descendants'], ['該当カテゴリのみ', 'self']]
  SETTING_OPTIONS = [['無効', 'disabled'], ['有効', 'enabled']]

  default_scope where(model: 'GpCategory::CategoryList')

  def layer
    setting_value(:layer).presence || LAYER_OPTIONS.first.last
  end

  def setting_state
    setting_value(:setting_state).presence || SETTING_OPTIONS.first.last
  end

  def category_type_id
    setting_value(:category_type_id).presence || nil
  end

  def category_id
    setting_value(:category_id).presence || nil
  end


  def content
    GpCategory::Content::CategoryType.find(super)
  end

  def category_types
    content.category_types
  end

  def public_category_types
    category_types.public
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

  def categorize_docs(docs)
    return docs unless category_type

    docs.select do |doc|
      category_ids = (doc.respond_to?(:category_ids) ? doc.category_ids : doc.categories.map(&:id))
      !(category_ids & self.categories.map(&:id)).empty?
    end
  end
end
