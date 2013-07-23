# encoding: utf-8
class Map::Piece::CategoryType < Cms::Piece
  default_scope where(model: 'Map::CategoryType')

  def content
    Map::Content::Marker.find(super)
  end
end
