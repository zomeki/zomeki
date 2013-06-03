# encoding: utf-8
class GpArticle::Admin::Docs::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  layout 'admin/files'

  def pre_dispatch
    if (@doc_id = params[:doc_id]) =~ /^[0-9a-z]{32}$/
      @tmp_unid = @doc_id
    else
      @doc = GpArticle::Doc.find(@doc_id)
    end

    return http_error(404) unless @content = GpArticle::Content::Doc.find_by_id(params[:content])
  end

  def index
    @item = Sys::File.new
    @items = Sys::File.where(tmp_id: @tmp_unid, parent_unid: @doc.try(:unid)).paginate(page: params[:page], per_page: 20).order(:name)
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
    @item.parent_unid = @doc.try(:unid)
    @item.allowed_type = @content.setting_value(:allowed_attachment_type)
    _create @item
  end

  def update
    @item = Sys::File.find(params[:id])
    @item.attributes = params[:item]
    @item.allowed_type = @content.setting_value(:allowed_attachment_type)
    @item.skip_upload
    _update @item
  end

  def destroy
    @item = Sys::File.find(params[:id])
    _destroy @item
  end

  def content
    if (file = Sys::File.where(tmp_id: @tmp_unid, parent_unid: @doc.try(:unid), name: "#{params[:basename]}.#{params[:extname]}").first)
      mt = Rack::Mime.mime_type(".#{params[:extname]}")
      type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
      disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
      send_file file.upload_path, :type => type, :filename => file.name, :disposition => disposition
    else
      http_error(404)
    end
  end
end
