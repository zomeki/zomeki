# encoding: utf-8
class Map::Content::Marker < Cms::Content
  IMAGE_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  MARKER_ORDER_OPTIONS = [['投稿日（昇順）', 'time_asc'], ['投稿日（降順）', 'time_desc'], ['カテゴリ順', 'category']]

  default_scope where(model: 'Map::Marker')

  has_many :markers, :foreign_key => :content_id, :class_name => 'Map::Marker', :dependent => :destroy

  after_initialize :set_default_settings

  def public_nodes
    nodes.public
  end

  def public_node
    public_nodes.order(:id).first
  end

#TODO: DEPRECATED
  def marker_node
    return @marker_node if @marker_node
    @marker_node = Cms::Node.where(state: 'public', content_id: id, model: 'Map::Marker').order(:id).first
  end

  def public_markers
    markers.public
  end

  def latitude
    lat_lng = setting_value(:lat_lng).to_s.split(',')
    return '35.702708' unless lat_lng.size == 2 # Mitaka
    lat_lng.first.strip
  end

  def longitude
    lat_lng = setting_value(:lat_lng).to_s.split(',')
    return '139.560831' unless lat_lng.size == 2 # Mitaka
    lat_lng.last.strip
  end

  def categories
    setting = Map::Content::Setting.find_by_id(settings.find_by_name('gp_category_content_category_type_id').try(:id))
    return GpCategory::Category.none unless setting
    setting.categories
  end

  def public_categories
    categories.public
  end

  def category_types
    GpCategory::CategoryType.where(id: categories.map(&:category_type_id))
  end

  def category_types_for_option
    category_types.map {|ct| [ct.title, ct.id] }
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

  def icon_image(item, goup=false)
    case item
    when GpCategory::CategoryType
      setting_value("#{item.class.name} #{item.id} icon_image").to_s
    when GpCategory::Category
      image = setting_value("#{item.class.name} #{item.id} icon_image").to_s
      if image.blank? && goup
        icon_image(item.parent || item.category_type, goup)
      else
        image
      end
    else
      ''
    end
  end

  def show_images?
    setting_value(:show_images) == 'visible'
  end

  def default_image
    setting_value(:default_image).to_s
  end

  def title_style
    setting_value(:title_style).to_s
  end

  def sort_markers(markers)
    case setting_value(:marker_order)
    when 'time_asc'
      markers.sort {|a, b| a.created_at <=> b.created_at }
    when 'time_desc'
      markers.sort {|a, b| b.created_at <=> a.created_at }
    when 'category'
      markers.sort do |a, b|
        next  0 if a.categories.empty? && b.categories.empty?
        next -1 if a.categories.empty?
        next  1 if b.categories.empty?
        a.categories.first.unique_sort_key <=> b.categories.first.unique_sort_key
      end
    else
      markers
    end
  end

  private

  def set_default_settings
    in_settings[:title_style] = '@title_link@' unless setting_value(:title_style)
  end
end
