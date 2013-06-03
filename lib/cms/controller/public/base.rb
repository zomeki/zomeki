class Cms::Controller::Public::Base < Sys::Controller::Public::Base
  include Cms::Controller::Layout
  
  before_filter :initialize_params
  after_filter :render_public_variables
  after_filter :render_public_layout
  
  def initialize_params
    #params.delete(:page)
    if Page.uri =~ /\.p[0-9]+\.html$/
      page = Page.uri.gsub(/.*\.p([0-9]+)\.html$/, '\\1')
      params[:page] = page.to_i if page !~ /^0+$/
    end
  end
  
  def pre_dispatch
    ## each processes before dispatch
  end
  
  def render_public_variables
    
  end
end
