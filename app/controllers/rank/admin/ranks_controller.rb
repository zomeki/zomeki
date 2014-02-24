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

    options

    @ranks   = rank_datas(@content, @term, @target, 20, nil, @gp_category, @category_type, @category)

    _index @ranks
  end

  def remote
    @options = options
    render :partial => 'remote'
  end

private
  def option_default
    [['すべて', '']]
  end

  def options
    @gp_category = params[:gp_category].to_i
    @gp_categories = option_default + gp_categories

    @category_type = params[:category_type].to_i
    @category_types = option_default
    @category_types = @category_types + category_types(@gp_category) if @gp_category > 0

    @category = params[:category].to_i
    @categories = option_default
    @categories = @categories + categories(@category_type) if @category_type > 0

    @category_type != 0 ? @categories : @category_types
  end
end