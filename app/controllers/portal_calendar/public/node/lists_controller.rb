# encoding: utf-8
class PortalCalendar::Public::Node::ListsController < PortalCalendar::Public::Node::BaseController

  def index
    params[:year]  = @today.strftime("%Y").to_s
    params[:month] = @today.strftime("%m").to_s

    return index_monthly
  end
  
  def index_monthly

		prepare_monthly_data
		
		respond_to do |format|
			format.xml  {render :xml => to_xml(@events)}
			format.html {render :action => "index_monthly"}
		end
  end
 
end