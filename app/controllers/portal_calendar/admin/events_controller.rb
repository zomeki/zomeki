# encoding: utf-8
class PortalCalendar::Admin::EventsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    #return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
#    default_url_options :content => @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    sort = nil
    sort = "event_start_date" if params[:sort] == "event_date"
    sort = "event_start_date DESC" if params[:sort] == "event_date -1"
    
    item = PortalCalendar::Event.new#.public#.readable
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order sort, 'updated_at DESC, id DESC'
    @items = item.find(:all)

		respond_to do |format|
			format.html		{_index @items}
			format.xml		{render :xml => @items.to_xml(:dasherize => false)}
		end
  end

  def show
    @item = PortalCalendar::Event.new.find(params[:id])
    #return error_auth unless @item.readable?

		@statuses = PortalCalendar::Event.get_status_valid_list(@content.id)
		@genres = PortalCalendar::Event.get_genre_valid_list(@content.id)

    _show @item
  end

  def new
    @item = PortalCalendar::Event.new({ :state => 'public' })

		@statuses = PortalCalendar::Event.get_status_valid_list(@content.id)
		@genres = PortalCalendar::Event.get_genre_valid_list(@content.id)
  end

  def create
    @item = PortalCalendar::Event.new(params[:item])
    @item.content_id = @content.id

		@statuses = PortalCalendar::Event.get_status_valid_list(@content.id)
		@genres = PortalCalendar::Event.get_genre_valid_list(@content.id)

    _create @item
  end

  def update
    @item = PortalCalendar::Event.new.find(params[:id])
    @item.attributes = params[:item]

		@statuses = PortalCalendar::Event.get_status_valid_list(@content.id)
		@genres = PortalCalendar::Event.get_genre_valid_list(@content.id)
		
    _update(@item)
  end

  def destroy
    @item = PortalCalendar::Event.new.find(params[:id])
    _destroy @item
  end

protected
end
