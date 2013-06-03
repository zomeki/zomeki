# encoding: utf-8
class Cms::Admin::StylesheetsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    @root      = "#{Core.site.public_path}/_themes"
    @path      = params[:path].to_s
    @path     += ".#{params[:format]}" if params[:format].present?
    @full_path = "#{@root}/#{@path}"
    @base_uri  = ["#{Core.site.public_path}/", "/"]

    Dir.mkdir(@root) unless Dir.exist?(@root)

    unless ::File.exist?(@full_path)
      return http_error(404) if flash[:notice]
      flash[:notice] = "指定されたパスは存在しません。（ #{@full_path.gsub(@base_uri[0], @base_uri[1])} ）"
      redirect_to(cms_stylesheets_path(''))
    end
  end
  
  def index
    @item = Cms::Stylesheet.find(@full_path, :root => @root, :base_uri => @base_uri)
    
    return show    if params[:do] == 'show'
    return new     if params[:do] == 'new'
    return edit    if params[:do] == 'edit'
    return update  if params[:do] == 'update'
    return rename  if params[:do] == 'rename'
    return move    if params[:do] == 'move'
    return destroy if params[:do] == 'destroy'
    if params[:do].nil? && !@item.directory?
      params[:do] = "show"
      return show
    end
    if request.post? && location = create
      return redirect_to(location)
    end
    
    @dirs  = @item.child_directories
    @files = @item.child_files
  end
  
  def show
    @item.read_body
    render 'show.html.erb'
  end
  
  def new
    render 'new.html.erb'
  end
  
  def edit
    @item.read_body
    render 'edit.html.erb'
  end
  
  def rename
    if request.put?
      if @item.rename(params[:item][:name])
        flash[:notice] = '更新処理が完了しました。'
        location = make_path(::File.dirname(@path))
        return redirect_to(location)
      end
    end
    render 'rename.html.erb'
  end
  
  def move
    if request.put?
      if @item.move(params[:item][:path])
        flash[:notice] = '更新処理が完了しました。'
        location = make_path(::File.dirname(@path))
        return redirect_to(location)
      end
    end
    render 'move.html.erb'
  end
  
  def create
    if params[:create_directory]
      if @item.create_directory(params[:item][:new_directory])
        flash[:notice] = 'ディレクトリを作成しました。'
        return make_path(@path)
      end
    elsif params[:create_file]
      if @item.create_file(params[:item][:new_file])
        flash[:notice] = 'ファイルを作成しました。'
        return make_path(::File.join(@path, params[:item][:new_file]), '?do=edit')
      end
    elsif params[:upload_file]
      if @item.upload_file(params[:item][:new_upload])
        flash[:notice] = 'アップロードが完了しました。'
        return make_path(@path)
      end
    end
    return false
  end
  
  def update
    @item.body = params[:item][:body]
    
    if @item.valid? && @item.save
      flash[:notice] = '更新処理が完了しました。'
      #location = cms_stylesheets_path(::File.dirname(@path))
      location = make_path(@path, '?do=edit')
      return redirect_to(location)
    end
    render 'edit.html.erb'
  end
  
  def destroy
    if @item.destroy
      flash[:notice] = "削除処理が完了しました。"
    else
      flash[:notice] = "削除処理に失敗しました。（#{@item.errors.full_messages.join(' ')}）"
    end
    dir = ::File.dirname(@path)
    location = make_path(dir)
    return redirect_to(location)
  end

protected
  def make_path(path, suffix = '')
    path = (path.blank? || path == '.') ? '' : "/#{path}"
    "#{cms_stylesheets_path}#{path}#{suffix}"
  end
end
