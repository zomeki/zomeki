class Cms::Admin::Navi::ConceptsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def index
    no_ajax = request.env['HTTP_X_REQUESTED_WITH'].to_s !~ /XMLHttpRequest/i
    render :layout => no_ajax
  end
  
  def show
    if params[:id] != Core.concept(:id).to_s
      Core.set_concept(session, params[:id])
    end
    
    @item = Core.concept
  end
end
