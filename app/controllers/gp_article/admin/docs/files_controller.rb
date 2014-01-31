# encoding: utf-8
class GpArticle::Admin::Docs::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  layout 'admin/files'

  def pre_dispatch
    return http_error(404) unless @content = GpArticle::Content::Doc.find_by_id(params[:content])

    if (@doc_id = params[:doc_id]) =~ /^[0-9a-z]{32}$/
      @tmp_unid = @doc_id
    else
      @doc = @content.all_docs.find(@doc_id)
    end
  end

  def index
    @item = Sys::File.new
    @items = Sys::File.where(tmp_id: @tmp_unid, parent_unid: @doc.try(:unid)).paginate(page: params[:page], per_page: 20).order(:name)
    if Page.smart_phone?
      render 'index_smart_phone', layout: 'admin/gp_article_files_smart_phone'
    else
      _index @items
    end
  end

  def show
    @item = Sys::File.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def create
    @item = Sys::File.new

    files = params[:files].presence || []
    names = params[:names].presence || []
    titles = params[:titles].presence || []
    success = failure = 0

    files.each_with_index do |file, i|
      attrs = { file: files[i], name: names[i], title: titles[i] }
      item = Sys::File.new(attrs)
      item.tmp_id = @tmp_unid
      item.parent_unid = @doc.try(:unid)
  
      if (duplicated = item.duplicated)
        item = duplicated
        item.attributes = attrs
      end
  
      item.allowed_type = @content.setting_value(:allowed_attachment_type)
      item.image_resize = params[:image_resize]
      if item.creatable? && item.save
        success += 1
      else
        failure += 1
        item.errors.to_a.each { |msg| @item.errors.add(:base, "#{attrs[:name]}: #{msg}") }
      end
    end

    flash.now[:notice] = "#{success}件の登録処理が完了しました。（#{I18n.l Time.now}）" if success != 0
    flash.now[:alert]  = "#{failure}件の登録処理に失敗しました。" if failure != 0

    @items = Sys::File.where(tmp_id: @tmp_unid, parent_unid: @doc.try(:unid)).paginate(page: params[:page], per_page: 20).order(:name)
    render :index
  end

  def update
    @item = Sys::File.find(params[:id])
    @item.attributes = params[:item]
    @item.allowed_type = @content.setting_value(:allowed_attachment_type)
    @item.image_resize = params[:image_resize]
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
