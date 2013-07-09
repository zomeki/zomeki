# encoding: utf-8
class GpCalendar::Content::Event < Cms::Content
  default_scope where(model: 'GpCalendar::Event')

  has_many :events, :foreign_key => :content_id, :class_name => 'GpCalendar::Event', :dependent => :destroy

  before_create :set_default_settings

  def event_node
    return @event_node if @event_node
    @event_node = Cms::Node.where(state: 'public', content_id: id, model: 'GpCalendar::Event').order(:id).first
  end

  def categories_for_option
    setting = GpCalendar::Content::Setting.find_by_id(settings.find_by_name('gp_category_content_category_type_id').try(:id))
    return [] unless setting
    setting.categories.map {|c| [c.title, c.id] }
  end

  private

  def set_default_settings
    in_settings[:list_style] = '@title(@date @group)' unless setting_value(:list_style)
    in_settings[:date_style] = '%Y年%m月%d日 %H時%M分' unless setting_value(:date_style)
  end
end
