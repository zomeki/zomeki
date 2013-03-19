# encoding: utf-8
class PortalArticle::Content::Setting < Cms::ContentSetting
  set_config :portal_group_id, :name => "ポータル記事分類コンテンツ",
    :options => []
  set_config :portal_bread_crumbs, :name => "ポータル記事分類/パンくず",
    :options => [['表示する','visible'],['表示しない','hidden']]
  set_config :docs_list_type, :name => "記事一覧表示形式",
    :options => [['展開形式','opened'],['一行形式','list']]
  set_config :word_dictionary, :name => "本文/単語変換辞書",
    :form_type => :text, :lower_text => "CSV形式（例　対象文字,変換後文字 ）"
  set_config :allowed_attachment_type, :name => "添付ファイル/許可する種類",
    :comment => "（例　<tt>gif,jpg,png,pdf,doc,xls,ppt,odt,ods,odp</tt> ）"
  set_config :default_map_position, :name => "地図/デフォルト座標",
    :comment => "（経度, 緯度）"
  set_config :inquiry_email_display, :name => "連絡先/メールアドレス表示",
    :options => [["表示","visible"],["非表示","hidden"]]
  set_config :recognition_type, :name => "承認/承認フロー",
    :options => [['管理者承認が必要','with_admin']]
  #set_config :default_recognizers, :name => "承認/デフォルト承認者"
  set_config :open_fb_comments, :name => 'Facebookコメント表示',
    :options => [['表示する', 'open'], ['表示しない', 'close']]
  set_config :archive_show_terms, :name => 'アーカイブ表示月数',
    :options => [['18ヶ月', '18'], ['12ヶ月', '12'], ['6ヶ月', '6']]
  set_config :archive_show_count_zero, :name => 'アーカイブ記事数ゼロ月の表示',
    :options => [['記事数ゼロを表示する', '1'], ['記事数ゼロを表示しない', '0']]

  validate :validate_value
  
  def validate_value
    case name
    when 'default_map_position'
      if !value.blank? && value !~ /^[0-9\.]+ *, *[0-9\.]+$/
        errors.add :value, :invalid
      end
    end
  end
  
  def config_options
    case name
    when 'portal_group_id'
      item = Cms::Content.new
      item.and :state, "public"
      item.and :model, "PortalGroup::Group"
      items = item.find(:all, :order => "site_id, name")
      return items.collect{|c| ["#{c.site.name} : #{c.name}", c.id] }
    when 'default_recognizers'
      users = Sys::User.new.enabled.find(:all, :order => :account)
      return users.collect{|c| [c.name_with_account, c.id.to_s]}
    end
    super
  end
  
  def value_name
    if !value.blank?
      case name
      when 'portal_group_id'
        item = Cms::Content.new
        item.and :id, value
        item.and :state, "public"
        item.and :model, "PortalGroup::Group"
        item = item.find(:first)
        return item ? "#{item.site.name} : #{item.name}" : nil
      when 'default_recognizers'
        user = Sys::User.find_by_id(value)
        return user.name_with_account if user
      end
    end
    super
  end
end
