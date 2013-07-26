# encoding: utf-8
class GpCalendar::Content::Event < Cms::Content
  default_scope where(model: 'GpCalendar::Event')

  has_many :events, :foreign_key => :content_id, :class_name => 'GpCalendar::Event', :dependent => :destroy

  before_create :set_default_settings

  def public_node
    Cms::Node.where(state: 'public', content_id: id, model: 'GpCalendar::Event').order(:id).first
  end

  def categories
    setting = GpCalendar::Content::Setting.find_by_id(settings.find_by_name('gp_category_content_category_type_id').try(:id))
    return [] unless setting
    setting.categories
  end

  def categories_for_option
    categories.map {|c| [c.title, c.id] }
  end

  def public_categories
    categories.public
  end

  def category_types
    GpCategory::CategoryType.where(id: categories.map(&:category_type_id))
  end

  def category_type_categories(category_type)
    category_type_id = (category_type.kind_of?(GpCategory::CategoryType) ? category_type.id : category_type.to_i )
    categories.select {|c| c.category_type_id == category_type_id }
  end

  def category_type_categories_for_option(category_type, opts={})
    include_descendants = opts[:include_descendants].nil? || opts[:include_descendants]
    if include_descendants
      category_type_categories(category_type).map{|c| c.descendants_for_option }.flatten(1)
    else
      category_type_categories(category_type).map {|c| [c.title, c.id] }
    end
  end

  def list_style
    setting_value(:list_style) || ''
  end

  def date_style
    setting_value(:date_style) || ''
  end

  def show_images?
    setting_value(:show_images) == 'visible'
  end

  def default_image
    setting_value(:default_image) || ''
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日（%a）' unless setting_value(:date_style)
    in_settings[:show_images] = 'visible' unless setting_value(:show_images)
  end
end
