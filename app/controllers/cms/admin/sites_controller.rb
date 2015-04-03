require 'yaml/store'

class Cms::Admin::SitesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    @item = Cms::Site.new # for search

    item = Cms::Site.new
    # システム管理者以外は所属サイトしか操作できない
    item.and :id, current_user.site_ids unless current_user.root?
    item.page  params[:page], params[:limit]
    item.order params[:sort], :id
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Cms::Site.new.find(params[:id])
    return error_auth unless @item.readable?

    load_sns_apps
    @item.load_file_transfer
    @item.load_site_settings

    _show @item
  end

  def new
    return error_auth unless Core.user.root? || Core.user.site_creatable?

    @sns_apps = {}

    @item = Cms::Site.new({
      :state      => 'public',
    })
  end

  def create
    return error_auth unless Core.user.root? || Core.user.site_creatable?

    @sns_apps = {}

    @item = Cms::Site.new(params[:item])
    @item.state = 'public'
    @item.portal_group_state = 'visible'
    _create(@item, notice: "登録処理が完了しました。 （反映にはWebサーバの再起動が必要です。）") do
      unless Core.user.root?
        @item.users << Core.user
      end
      make_concept(@item)
      make_node(@item)
      make_files(@item)
      update_config
      save_sns_apps
    end
  end

  def update
    @item = Cms::Site.new.find(params[:id])
    @item.attributes = params[:item]

    @sns_apps = params[:sns_apps]

    _update @item do
      make_node(@item)
      make_files(@item)
      update_config
      save_sns_apps
    end
  end

  def destroy
    @item = Cms::Site.new.find(params[:id])
    _destroy(@item) do
      cookies.delete(:cms_site)
      update_config
    end
  end

  def show_portal
    @item = Cms::Site.new.find(params[:id])
    @item.portal_group_state = "visible"
    @item.save(:validate => false)

    @item.contents.each do |content|
      query    = {:portal_group_state => "visible"}
      criteria = {:content_id => content.id}
      PortalArticle::Doc.update_all(query, criteria)
    end

    flash[:notice] = "ポータルに公開しました。"
    redirect_to :action => :show
  end

  def hide_portal
    @item = Cms::Site.new.find(params[:id])
    @item.portal_group_state = "hidden"
    @item.save(:validate => false)

    @item.contents.each do |content|
      query    = {:portal_group_state => "hidden"}
      criteria = {:content_id => content.id}
      PortalArticle::Doc.update_all(query, criteria)
    end

    flash[:notice] = "ポータル公開を終了しました。"
    redirect_to :action => :show
  end

protected
  def make_concept(item)
    concept = Cms::Concept.new({
      :parent_id => 0,
      :site_id   => item.id,
      :state     => 'public',
      :level_no  => 1,
      :sort_no   => 1,
      :name      => item.name
    })
    concept.save
  end

  def make_node(item)
    if node = item.root_node
      if node.title != item.name
        node.title = item.name
        node.save
      end
      return true
    end

    node = Cms::Node.new({
      :site_id      => item.id,
      :state        => 'public',
      :published_at => Core.now,
      :parent_id    => 0,
      :route_id     => 0,
      :model        => 'Cms::Directory',
      :directory    => 1,
      :name         => '/',
      :title        => item.name
    })
    node.save(:validate => false)

    top = Cms::Node.new({
      :site_id      => item.id,
      :state        => 'public',
      :published_at => Core.now,
      :parent_id    => node.id,
      :route_id     => node.id,
      :model        => 'Cms::Page',
      :directory    => 0,
      :name         => 'index.html',
      :title        => item.name
    })
    top.save(:validate => false)

    item.node_id = node.id
    item.save
  end

  def make_files(item)
    dir = item.public_path
    FileUtils.mkdir_p(dir) unless ::File.exist?(dir)

    dir = "#{item.public_path}/_dynamic"
    FileUtils.mkdir_p(dir) unless ::File.exist?(dir)

    dir = item.config_path
    FileUtils.mkdir_p(dir) unless ::File.exist?(dir)

    file = "#{item.config_path}/rewrite.conf"
    FileUtils.touch(file) unless ::File.exist?(file)
  end

  def update_config
    Cms::Site.put_virtual_hosts_config
  end

  private

  def load_sns_apps
    @sns_apps = {}

    host = URI.parse(@item.full_uri).host
    return unless host

    db = YAML::Store.new(Rails.root.join('config/sns_apps.yml'))
    db.transaction do
      begin
        facebook = db['facebook'][host]
        @sns_apps['facebook_app_id'] = facebook['id']
        @sns_apps['facebook_app_secret'] = facebook['secret']
      rescue => e
        warn_log "Failed to load facebook apps: #{e.message}"
      end

      begin
        twitter = db['twitter'][host]
        @sns_apps['twitter_consumer_key'] = twitter['key']
        @sns_apps['twitter_consumer_secret'] = twitter['secret']
      rescue => e
        warn_log "Failed to load twitter apps: #{e.message}"
      end
    end
  end

  def save_sns_apps
    host = URI.parse(@item.full_uri).host
    return unless host

    sns_apps = params[:sns_apps]

    db = YAML::Store.new(Rails.root.join('config/sns_apps.yml'))
    db.transaction do
      begin
        facebook = db['facebook']
        unless facebook[host].kind_of?(Hash)
          facebook[host] = {}
          facebook['default'].each do |key, value|
            facebook[host][key] = value
          end
        end

        facebook = facebook[host]
        facebook['id'] = sns_apps['facebook_app_id']
        facebook['secret'] = sns_apps['facebook_app_secret']
      rescue => e
        warn_log "Failed to save facebook apps: #{e.message}"
      end

      begin
        twitter = db['twitter']
        unless twitter[host].kind_of?(Hash)
          twitter[host] = {}
          twitter['default'].each do |key, value|
            twitter[host][key] = value
          end
        end

        twitter = twitter[host]
        twitter['key'] = sns_apps['twitter_consumer_key']
        twitter['secret'] = sns_apps['twitter_consumer_secret']
      rescue => e
        warn_log "Failed to save twitter apps: #{e.message}"
      end
    end
  end
end
