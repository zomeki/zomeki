class Cms::Controller::Public::Base < Sys::Controller::Public::Base
  include Cms::Controller::Layout

  before_filter :initialize_params
  after_filter :render_public_variables
  after_filter :render_public_layout

  def initialize_params
    if m = Page.uri.match(/\.p(\d+)\.html(\.r)?\z/)
      page = m[1].to_i
      params[:page] = page if page > 0
    end
  end

  def pre_dispatch
    ## each processes before dispatch
  end

  def render_public_variables
  end
end
