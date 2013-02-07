# encoding: utf-8
class Tag::Piece::Tag < Cms::Piece
  default_scope where(model: 'Tag::Tag')

  def content
    Tag::Content::Tag.find(super)
  end
end
