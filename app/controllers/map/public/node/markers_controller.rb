# encoding: utf-8
class Map::Public::Node::MarkersController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Map::Content::Marker.find_by_id(@node.content.id)
    return http_error(404) unless @content
  end

  def index
  end
end
