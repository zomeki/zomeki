# encoding: utf-8
class Rank::Public::Piece::RanksController < Sys::Controller::Public::Base
  include Rank::Controller::Rank

  def pre_dispatch
    @piece = Rank::Piece::Rank.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece
  end

  def index
    render :text => '' and return if @piece.ranking_target.blank? || @piece.ranking_term.blank?

    @term   = @piece.ranking_term
    @target = @piece.ranking_target
    @ranks  = rank_datas(@piece.content, @term, @target, @piece.display_count, @piece.content.setting_value(:category_option))

    render :text => '' if @ranks.empty?
  end
end
