# encoding: utf-8
class GpCalendar::Content::Event < Cms::Content
  IMAGE_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  EVENT_SYNC_OPTIONS = [['有効', 'enabled'], ['無効', 'disabled']]

  default_scope where(model: 'GpCalendar::Event')

  has_many :events, :foreign_key => :content_id, :class_name => 'GpCalendar::Event', :dependent => :destroy
  has_many :holidays, :foreign_key => :content_id, :class_name => 'GpCalendar::Holiday', :dependent => :destroy

  before_create :set_default_settings

  def public_nodes
    nodes.public
  end

  def public_node
    public_nodes.order(:id).first
  end

  def public_events
    events.public
  end

  def categories
    setting = GpCalendar::Content::Setting.find_by_id(settings.find_by_name('gp_category_content_category_type_id').try(:id))
    return GpCategory::Category.none unless setting
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

  def category_type_categories_for_option(category_type, include_descendants: true)
    if include_descendants
      category_type_categories(category_type).map{|c| c.descendants_for_option }.flatten(1)
    else
      category_type_categories(category_type).map {|c| [c.title, c.id] }
    end
  end

  def list_style
    setting_value(:list_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def show_images?
    setting_value(:show_images) == 'visible'
  end

  def default_image
    setting_value(:default_image).to_s
  end

  def image_cnt
    setting_extra_value(:show_images, :image_cnt).to_i
  end

  def event_sync_import?
    setting_value(:event_sync_import) == 'enabled'
  end

  def event_sync_export?
    setting_value(:event_sync_export) == 'enabled'
  end

  def event_sync_source_hosts
    setting_extra_value(:event_sync_import, :source_hosts).to_s
  end

  def event_sync_destination_hosts
    setting_extra_value(:event_sync_export, :destination_hosts).to_s
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title_link@' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日（%a）' unless setting_value(:date_style)
    in_settings[:show_images] = 'visible' unless setting_value(:show_images)
    in_settings[:event_sync_import] = 'disabled' unless setting_value(:event_sync_import)
    in_settings[:event_sync_export] = 'disabled' unless setting_value(:event_sync_export)
  end
end
