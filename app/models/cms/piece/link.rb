# encoding: utf-8
class Cms::Piece::Link < Cms::Piece
  has_many :link_items, :foreign_key => :piece_id, :order => :sort_no,
    :class_name => 'Cms::PieceLinkItem', :dependent => :destroy
end