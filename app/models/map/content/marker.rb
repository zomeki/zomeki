# encoding: utf-8
class Map::Content::Marker < Cms::Content
  default_scope where(model: 'Map::Marker')

  def marker_node
    return @marker_node if @marker_node
    @marker_node = Cms::Node.where(state: 'public', content_id: id, model: 'Map::Marker').order(:id).first
  end
end
