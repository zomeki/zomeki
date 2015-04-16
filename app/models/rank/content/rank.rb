# encoding: utf-8
class Rank::Content::Rank < Cms::Content
  default_scope where(model: 'Rank::Rank')

  has_many :pieces, foreign_key: :content_id, class_name: 'Rank::Piece::Rank', dependent: :destroy
  has_many :ranks, foreign_key: :content_id, class_name: 'Rank::Total', dependent: :destroy

  def public_nodes
    nodes.public
  end

  def public_node
    public_nodes.order(:id).first
  end

  #TODO: DEPRECATED
  def rank_node
    return @rank_node if @rank_node
    @rank_node = Cms::Node.where(state: 'public', content_id: id, model: 'Rank::Rank').order(:id).first
  end
end
