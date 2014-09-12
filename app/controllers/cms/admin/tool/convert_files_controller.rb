# encoding: utf-8
class Cms::Admin::Tool::ConvertFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    @site_url  = params[:site_url] || ""
    @root      = "#{Tool::Convert::SITE_BASE_DIR}/#{@site_url}"
    @path      = params[:path].to_s
    @full_path = "#{@root}/#{@path}"
    @rel_path  = "#{@site_url}/#{@path}"
    @base_uri  = ["#{Tool::Convert::SITE_BASE_DIR}/", "/"]

    @item = Tool::SiteContent.new(@site_url, @full_path, :root => @root, :base_uri => @base_uri)

    if @item.file?
      @rel_path = @rel_path.sub(/\/[^\/]*$/, '')
      params[:do] = "show"
      return show
    else
      return show if params[:do] == 'show'
    end

    @dirs  = @item.child_directories
    @files = @item.child_files
  end

  def show
    render :show
  end
end
