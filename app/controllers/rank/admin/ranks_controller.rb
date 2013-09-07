# encoding: utf-8
class Rank::Admin::RanksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Rank::Controller::Rank

  after_filter :flash_clear

  def pre_dispatch
    return error_auth unless @content = Rank::Content::Rank.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index
    if @content.ranks.empty?
      start_date = (DateTime.parse(@content.setting_value(:start_date)) rescue nil) || Time.now - 1.month

      get_access(@content, start_date)
    end

    rank_table = Rank::Rank.arel_table
    @target = params[:target]
    @target = 'pageviews' unless @target == 'pageviews' || @target == 'visitors'
    from    = params[:from].presence || '0000-00-00'
    to      = params[:to].presence   || '9999-99-99'
    @ranks  = @content.ranks.where(rank_table[:date].gteq(from).and(rank_table[:date].lteq(to))).select('*').select(rank_table[@target].sum.as('accesses')).group(rank_table[:page_path]).order('accesses DESC').paginate(page: params[:page], per_page: 50)

    _index @ranks
  end

  def flash_clear
    flash[:alert ] = nil
    flash[:notice] = nil
  end
end