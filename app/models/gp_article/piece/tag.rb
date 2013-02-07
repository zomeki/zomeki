# encoding: utf-8
class GpArticle::Piece::Tag < Cms::Piece
  default_scope where(model: 'GpArticle::Tag')

  def content
    GpArticle::Content::Doc.find(super)
  end
end
