# encoding: utf-8
class GpCalendar::Admin::Events::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  layout 'admin/files'

  def pre_dispatch
    return http_error(404) unless @content = GpCalendar::Content::Event.find_by_id(params[:content])

    if (@event_id = params[:event_id]) =~ /^[0-9a-z]{32}$/
      @tmp_unid = @event_id
    else
      @event = @content.events.find(@event_id)
    end
  end

  def index
    @item = Sys::File.new
    @items = Sys::File.where(tmp_id: @tmp_unid, parent_unid: @event.try(:unid)).paginate(page: params[:page], per_page: 20).order(:name)
    _index @items
  end

  def show
    @item = Sys::File.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def create
    @item = Sys::File.new(params[:item])
    @item.tmp_id = @tmp_unid
    @item.parent_unid = @event.try(:unid)

    if (duplicated = @item.duplicated)
      @item = duplicated
      @item.attributes = params[:item]
    end

    @item.allowed_type = 'gif,jpg,png'
    @item.image_resize = params[:image_resize]
    _create @item
  end

  def update
    @item = Sys::File.find(params[:id])
    @item.attributes = params[:item]
    @item.allowed_type = 'gif,jpg,png'
    @item.image_resize = params[:image_resize]
    @item.skip_upload
    _update @item
  end

  def destroy
    @item = Sys::File.find(params[:id])
    _destroy @item
  end

  def content
    if (file = Sys::File.where(tmp_id: @tmp_unid, parent_unid: @event.try(:unid), name: "#{params[:basename]}.#{params[:extname]}").first)
      mt = Rack::Mime.mime_type(".#{params[:extname]}")
      type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
      disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
      send_file file.upload_path, :type => type, :filename => file.name, :disposition => disposition
    else
      http_error(404)
    end
  end
end
