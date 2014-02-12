# encoding: utf-8
class Rank::Admin::RanksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Rank::Controller::Rank

  def pre_dispatch
    return error_auth unless @content = Rank::Content::Rank.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    @terms   = ranking_terms
    @targets = ranking_targets
    @term    = param_check(@terms,   params[:term])
    @target  = param_check(@targets, params[:target])
    @ranks   = rank_datas(@content, @term, @target, 20)
    _index @ranks
  end
end