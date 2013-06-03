# encoding: utf-8
class Map::Content::Marker < Cms::Content
  default_scope where(model: 'Map::Marker')

  has_many :markers, :foreign_key => :content_id, :class_name => 'Map::Marker', :dependent => :destroy

  def marker_node
    return @marker_node if @marker_node
    @marker_node = Cms::Node.where(state: 'public', content_id: id, model: 'Map::Marker').order(:id).first
  end

  def public_markers
    markers.public
  end
end
