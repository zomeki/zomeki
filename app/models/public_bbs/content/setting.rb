# encoding: utf-8
class PublicBbs::Content::Setting < Cms::ContentSetting
  set_config :portal_group_id, :name => 'ポータル記事分類',
    :options => []
  set_config :threads_list_type, :name => 'スレッド一覧表示形式',
    :options => [['展開形式', 'opened'], ['一行形式', 'list']]
  set_config :new_thread_creation, :name => '新規スレッド作成',
    :options => [['許可', 'allow'], ['拒否', 'deny']]

  validate :validate_value

  def validate_value
  end

  def config_options
    case name
    when 'portal_group_id'
      item = Cms::Content.new
      item.and :state, 'public'
      item.and :model, 'PortalGroup::Group'
      items = item.find(:all, :order => 'site_id, name')
      return items.map {|c| ["#{c.site.name} : #{c.name}", c.id] }
    end
    super
  end

  def value_name
    unless value.blank?
      case name
      when 'portal_group_id'
        item = Cms::Content.new
        item.and :id, value
        item.and :state, 'public'
        item.and :model, 'PortalGroup::Group'
        item = item.find(:first)
        return item ? "#{item.site.name} : #{item.name}" : nil
      end
    end
    super
  end
end
