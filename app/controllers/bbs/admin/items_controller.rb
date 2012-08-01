# encoding: utf-8
require "rexml/document"
class Bbs::Admin::ItemsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    #return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Bbs::Content::Base.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    
    @node = @content.thread_node
    @node_uri = File.join(Core.site.full_uri, @node.public_uri) if @node
    
    @admin_password = @content.setting_value(:admin_password)
  end

  def index
    unless @node
      return render(:text => "ディレクトリを作成してください。", :layout => true)
    end
    
    page  = (params[:page] || 1).to_i
    limit = 10
    
    res = Util::Http::Request.send("#{@node_uri}index.xml?page=#{page}&limit=#{limit}")
    doc = REXML::Document.new(res.body)
    return render(:text => "投稿データの取得に失敗しました。", :layout => true) unless doc.root
    
    @items = doc.root
    total = doc.root.elements["total_entries"].text.to_i
    
    @pagination = Util::Html::SimplePagination.new
    @pagination.prev_label = "前のページ"
    @pagination.next_label = "次のページ"
    @pagination.prev_uri   = "?page=#{page-1}" if page > 1
    @pagination.next_uri   = "?page=#{page+1}" if page < (total.to_f / limit.to_f).ceil
  end
  
  def show
    @thread_id = params[:id]
    @res_id    = nil
    if params[:id] =~ /\-/
      @thread_id, @res_id = params[:id].split("-")
    end
    
    res = Util::Http::Request.send("#{@node_uri}#{@thread_id}/index.xml")
    doc = REXML::Document.new(res.body)
    return render(:text => "投稿データの取得に失敗しました。", :layout => true) unless doc.root
    
    if @res_id == nil
      @item = doc.root.elements["item"]
    else
      doc.root.elements["item"].elements.each("item") do |res|
        if @res_id == res.elements["id"].text
          @item = res
          break
        end
      end
    end
    
    return http_error(404) unless @item
  end

  def new
    return error_auth
  end

  def create
    return error_auth
  end

  def update
    return error_auth
  end
  
  def destroy
    id = params[:id] =~ /\-/ ? params[:id].gsub(/.*\-/, "") : params[:id]
    
    uri = "#{@node_uri}delete.xml"
    body = {:_method => "DELETE", :no => id, :password => @admin_password}
    res = Util::Http::Request.post(uri, body)
    
    if res && res.code == "200"
      flash[:notice] = '削除処理が完了しました。'
      redirect_to url_for(:action => :index)
    else
      flash.now[:notice] = '削除処理に失敗しました。'
      show
      render :action => :show
    end
  end
end
