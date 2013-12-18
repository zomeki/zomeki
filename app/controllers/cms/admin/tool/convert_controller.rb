# encoding: utf-8
class Cms::Admin::Tool::ConvertController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
  end

  def index
    @item  = []
    def @item.site_url ; @site_url ; end
    def @item.site_url=(v) ; @site_url = v ; end
    if request.post?
      @item.site_url= params[:item][:site_url]
      if @item.site_url.present?
        Thread.fork(@item.site_url) do |site_url|
          result = Util::Convert.download_site(site_url)
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
    @root      = "#{Util::Convert::SITE_BASE_DIR}/#{@site_url}"
    @path      = params[:path].to_s
    @full_path = "#{@root}/#{@path}"
    @base_uri  = ["#{Util::Convert::SITE_BASE_DIR}/", "/"]

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

end

