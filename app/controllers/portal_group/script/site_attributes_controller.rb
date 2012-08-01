# encoding: utf-8
class PortalGroup::Script::SiteAttributesController < Cms::Controller::Script::Publication
  def self.publishable?
    false
  end
  
  def publish
    @node.close_page
    
    render :text => "OK"
  end
end
