class PortalGroup::Admin::BusinessesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    #default_url_options[:content] = @content
    
    if params[:parent] == '0'
      @parent = PortalGroup::Business.new({
        :level_no => 0
      })
      @parent.id = 0
    else
      @parent = PortalGroup::Business.new.find(params[:parent])
    end
  end
  
  def index
    item = PortalGroup::Business.new#.readable
    item.and :parent_id, @parent
    item.and :content_id, @content
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = PortalGroup::Business.new.find(params[:id])
    _show @item
  end

  def new
    @item = PortalGroup::Business.new({
      :state      => 'public',
      :sort_no    => 1,
    })
  end
  
  def create
    @item = PortalGroup::Business.new(params[:item])
    @item.site_id    = Core.site.id
    @item.content_id = @content.id
    @item.parent_id  = @parent.id
    @item.level_no   = @parent.level_no + 1
    _create @item
  end
  
  def update
    @item = PortalGroup::Business.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = PortalGroup::Business.new.find(params[:id])
    _destroy @item
  end
end
