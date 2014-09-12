# encoding: utf-8
class Cms::Admin::Tool::ConvertController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    @item  = []
    def @item.site_url ; @site_url ; end
    def @item.site_url=(v) ; @site_url = v ; end
    if request.post?
      @item.site_url= params[:item][:site_url]
      if @item.site_url.present?
        Thread.fork(@item.site_url) do |site_url|
          result = Tool::Convert.download_site(site_url)
          if result
            puts "#{site_url} download successful completed!"
          else
            puts "#{site_url} download failure!"
          end
        end
        sleep 1
      end
      redirect_to tool_convert_url
    end
  end

  # ファイル一覧
  def file_list
    @site_url  = params[:site_url] || ""
    @root      = "#{Tool::Convert::SITE_BASE_DIR}/#{@site_url}"
    @path      = params[:path].to_s
    @full_path = "#{@root}/#{@path}"
    @base_uri  = ["#{Tool::Convert::SITE_BASE_DIR}/", "/"]

    @item = Tool::SiteContent.new(@site_url, @full_path, :root => @root, :base_uri => @base_uri)
    return show    if params[:do] == 'show'

    if params[:do].nil? && @item.file?
      params[:do] = "show"
      return show
    end

    @dirs  = @item.child_directories
    @files = @item.child_files
  end

  def show
    # @item.read_body
    render :show
  end

  # 変換情報の書き込み
  def convert_setting
    @item = Tool::ConvertSetting.new(params[:item])
    if @item.site_url.present? && Tool::ConvertSetting.find_by_site_url(@item.site_url).present?
      @item = Tool::ConvertSetting.find_by_site_url(@item.site_url)
    end

    if request.post?
      # 書き込みの場合
      if @item.new_record?
        if @item.save
          flash[:notice] = "登録処理が完了しました。（#{I18n.l Time.now}）"
          redirect_to tool_convert_setting_path("item[site_url]" => @item.site_url)
        else
          flash.now[:alert] = '登録処理に失敗しました。'
        end
      else
        if @item.update_attributes(params[:item])
          flash[:notice] = "更新処理が完了しました。（#{I18n.l Time.now}）"
          redirect_to tool_convert_setting_path("item[site_url]" => @item.site_url) 
        else
          flash.now[:alert] = '更新処理に失敗しました。'
        end
      end
    end
  end

  # サイトの導入(書き込み)
  def import_site
    @item  = []
    def @item.site_url ; @site_url ; end
    def @item.site_url=(v) ; @site_url = v ; end
    def @item.content_id ; @content_id ; end
    def @item.content_id=(v) ; @content_id = v ; end

    if request.post? && params[:item].present?
      @item.site_url = params[:item][:site_url]
      @item.content_id = params[:item][:content_id]
      if params[:item][:site_url].present? && params[:item][:content_id].present?
        setting = Tool::ConvertSetting.find_by_site_url(params[:item][:site_url])
        if setting
          Tool::Convert.import_site(params[:item], setting)
          Tool::Convert.process_link
          redirect_to tool_convert_import_site_url
        else
          flash.now[:alert] = '選択したサイトURLに対して、変換情報が存在しません。変換画面で追加してください。'
        end
      else
        flash.now[:alert] = 'サイトURLとコンテンツIDを選択してください。'
      end
    end
  end

end

