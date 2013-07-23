# encoding: utf-8
class Map::Content::Marker < Cms::Content
  default_scope where(model: 'Map::Marker')

  has_many :markers, :foreign_key => :content_id, :class_name => 'Map::Marker', :dependent => :destroy

  def public_node
    Cms::Node.where(state: 'public', content_id: id, model: 'Map::Marker').order(:id).first
  end

  def marker_node
    return @marker_node if @marker_node
    @marker_node = Cms::Node.where(state: 'public', content_id: id, model: 'Map::Marker').order(:id).first
  end

  def public_markers
    markers.public
  end

  def latitude
    lat_lng = setting_value(:lat_lng).to_s.split(',')
    return '' unless lat_lng.size == 2
    lat_lng.first.strip
  end

  def longitude
    lat_lng = setting_value(:lat_lng).to_s.split(',')
    return '' unless lat_lng.size == 2
    lat_lng.last.strip
  end

  def categories
    setting = Map::Content::Setting.find_by_id(settings.find_by_name('gp_category_content_category_type_id').try(:id))
    return [] unless setting
    setting.categories
  end

  def category_types
    GpCategory::CategoryType.where(id: categories.map(&:category_type_id))
  end

  def category_type_categories(category_type)
    category_type_id = (category_type.kind_of?(GpCategory::CategoryType) ? category_type.id : category_type.to_i )
    categories.select {|c| c.category_type_id == category_type_id }
  end

  def category_type_categories_for_option(category_type, include_descendants: true)
    if include_descendants
      category_type_categories(category_type).map{|c| c.descendants_for_option }.flatten(1)
    else
      category_type_categories(category_type).map {|c| [c.title, c.id] }
    end
  end
end
