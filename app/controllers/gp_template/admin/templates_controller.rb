# encoding: utf-8
class GpTemplate::Admin::TemplatesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = GpTemplate::Content::Template.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    @item = @content.templates.find(params[:id]) if params[:id].present?
  end

  def index
    if params[:check_boxes]
      @items = @content.templates.public
      return render 'index_check_boxes', :layout => false
    elsif params[:options]
      @items = @content.templates.public
      return render 'index_options', :layout => false
    end
    
    @items = @content.templates.paginate(page: params[:page], per_page: 30)
    _index @items
  end

  def show
    _show @item
  end

  def new
    @item = @content.templates.build
  end

  def create
    @item = @content.templates.build(params[:item])
    _create @item
  end

  def update
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    _destroy @item
  end

  def duplicate(item)
    if dupe_item = item.duplicate
      flash[:notice] = '複製処理が完了しました。'
      respond_to do |format|
        format.html { redirect_to gp_template_templates_path }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "複製処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(:action => :show) }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def form
    @template_values = params[:item] && params[:item][:template_values] ? params[:item][:template_values] : {}
    render 'form', :layout => false
  end
end
