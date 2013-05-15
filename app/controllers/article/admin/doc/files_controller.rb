class Article::Admin::Doc::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    simple_layout
    @parent = params[:parent]
    @tmp    = true if @parent.size == 32
    
    if params[:content]
      @content = Article::Content::Doc.find_by_id(params[:content])
    end
    return http_error(404) if @content.nil? || @content.model != 'Article::Doc'
  end
  
  def index
    @item = Sys::File.new#.readable
    if @tmp
      @item.and :tmp_id, @parent
      @item.and :parent_unid, 'IS', nil
    else
      @item.and :tmp_id, 'IS', nil
      @item.and :parent_unid, @parent
    end
    @item.page  params[:page], params[:limit]
    @item.order params[:sort], :name
    @items = @item.find(:all)
    _index @items
  end
  
  def show
    @item = Sys::File.new.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::File.new({
    })
  end
  
  def create
    @item = Sys::File.new(params[:item])
    if @tmp
      @item.tmp_id      = @parent
    else
      @item.parent_unid = @parent
    end
    
    @item.allowed_type = @content.setting_value(:allowed_attachment_type)
    
    _create @item
  end
  
  def update
    @item = Sys::File.new.find(params[:id])
    @item.attributes   = params[:item]
    @item.allowed_type = @content.setting_value(:allowed_attachment_type)
    @item.skip_upload
    
    _update @item
  end
  
  def destroy
    @item = Sys::File.new.find(params[:id])
    _destroy @item
  end
  
  def download
    item = Sys::File.new
    if @tmp
      item.and :tmp_id, @parent
      item.and :parent_unid, 'IS', nil
    else
      item.and :tmp_id, 'IS', nil
      item.and :parent_unid, @parent
    end
    if params[:id]
      item.and :id, params[:id]
    elsif params[:name] && params[:format]
      item.and :name, "#{params[:name]}.#{params[:format]}"
    end
    return http_error(404) unless @file = item.find(:first)
    
    send_file @file.upload_path, :type => @file.mime_type, :filename => @file.name, :disposition => 'inline'
  end
end
