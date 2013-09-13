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
      start_date = (DateTime.parse(@content.setting_value(:start_date)) rescue nil)

      get_access(@content, start_date)
    end

    per_page   = 20

    rank_table = Rank::Rank.arel_table
    @target = params[:target]
    @target = 'pageviews' unless @target == 'pageviews' || @target == 'visitors'
    from    = params[:from].presence || '2005-01-01'
    to      = params[:to].presence   || Date.today.strftime('%F')
    @ranks  = @content.ranks.where(rank_table[:date].gteq(from).and(rank_table[:date].lteq(to))).select('*').select(rank_table[@target].sum.as('accesses')).group(rank_table[:page_path]).order('accesses DESC').paginate(page: params[:page], per_page: per_page)

    _index @ranks
  end

  def flash_clear
    flash[:alert ] = nil
    flash[:notice] = nil
  end
end