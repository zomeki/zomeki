# encoding: utf-8
class AdBanner::Admin::BannersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = AdBanner::Content::Banner.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    items = @content.banners.except(:order).order('created_at DESC')

    items = if params[:published].present?
              items.published
            elsif params[:closed].present?
              items.closed
            else
              items
            end

    @items = items.paginate(page: params[:page], per_page: 50)

    _index @items
  end

  def show
    @item = @content.banners.find(params[:id])
    _show @item
  end

  def new
    @item = @content.banners.build
  end

  def create
    @item = @content.banners.build(params[:item])
    _create @item
  end

  def update
    @item = @content.banners.find(params[:id])
    @item.attributes = params[:item]
    @item.skip_upload if @item.file.blank? && @item.file_exist?
    _update @item
  end

  def destroy
    @item = @content.banners.find(params[:id])
    _destroy @item
  end

  def file_content
    item = @content.banners.find(params[:id])
    mt = item.mime_type.presence || Rack::Mime.mime_type(File.extname(item.name))
    type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
    disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
    send_file item.upload_path, :type => type, :filename => item.name, :disposition => disposition
  end
end
