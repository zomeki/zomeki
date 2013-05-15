# encoding: utf-8
class Laby::Script::DocsController < Cms::Controller::Script::Publication
  def self.publishable?
    false
  end
  
  def publish
    render :text => "OK"
  end
end
