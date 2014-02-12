# encoding: utf-8
class Rank::Content::Rank < Cms::Content
  default_scope where(model: 'Rank::Rank')

  has_many :ranks, :foreign_key => :content_id, :class_name => 'Rank::Total', :dependent => :destroy

  def rank_node
    return @rank_node if @rank_node
    @rank_node = Cms::Node.where(state: 'public', content_id: id, model: 'Rank::Rank').order(:id).first
  end

end
