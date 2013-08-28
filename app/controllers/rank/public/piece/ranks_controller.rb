# encoding: utf-8
class Rank::Public::Piece::RanksController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Rank::Piece::Rank.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece
  end

  def index
    select_col = @piece.in_settings[:ranking_target]

    t = Date.today
    case @piece.in_settings[:ranking_term]
    when 'previous_days'
      from = t.yesterday
      to   = t.yesterday
    when 'last_weeks'
    	wday = t.wday == 0 ? 7 : t.wday
      from = t - (6 + wday).days
      to   = t - wday.days
    when 'last_months'
      from = (t - 1.month).beginning_of_month
      to   = (t - 1.month).end_of_month
    when 'this_weeks'
      from = t.yesterday - 7.days
      to   = t.yesterday
    end

    per_page = @piece.in_settings[:display_count].to_i == 0 ? 50 : @piece.in_settings[:display_count].to_i

    rank_table = Rank::Rank.arel_table
    @ranks = @piece.content.ranks.where(rank_table[:date].gteq(from.strftime('%F')).and(rank_table[:date].lteq(to.strftime('%F')))).select('*').select(rank_table[select_col].sum.as('accesses')).group(rank_table[:page_path]).order('accesses DESC').paginate(page: params[:page], per_page: per_page)

    render :text => '' if @ranks.empty?
  end
end
