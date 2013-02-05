# encoding: utf-8
class PortalCalendar::Public::Node::ListsController < PortalCalendar::Public::Node::BaseController

  def index
    params[:year]  = @today.strftime("%Y").to_s
    params[:month] = @today.strftime("%m").to_s

    return index_monthly
  end
  
  def index_monthly
    return http_error(404) unless validate_date
    return http_error(404) if Date.new(@year, @month, 1) < @min_date
    return http_error(404) if Date.new(@year, @month, 1) > @max_date

		@events, @items = prepare_monthly_data

		respond_to do |format|
			format.xml  {render :xml => to_xml(@events)}
			format.html {render :action => "index_monthly"}
		end
  end
 
end