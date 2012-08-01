# encoding: utf-8
class PortalGroup::Content::Setting < Cms::ContentSetting
  set_config :sites_list_type, :name => "サイト一覧表示形式",
    :options => [['展開形式','opened'],['一行形式','list']]
  set_config :docs_list_type, :name => "記事一覧表示形式",
    :options => [['展開形式','opened'],['一行形式','list']]
  
  validate :validate_value
  
  def validate_value
  end
  
  def config_options
    super
  end
  
  def value_name
    super
  end
end