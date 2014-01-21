# encoding: utf-8
class Rank::Public::Node::PreviousDaysController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = Rank::Content::Rank.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index

    t = Date.today
    from = t.yesterday
    to   = t.yesterday

    select_col = 'pageviews' # 'visitors'
    per_page   = 20
    exclusion  = @content.setting_value(:exclusion_url).strip.split(/[ |\t|\r|\n|\f]+/) rescue exclusion = ''
    hostname   = URI.parse(Core.site.full_uri).host

    rank_table = Rank::Rank.arel_table
    @ranks = @content.ranks.where(rank_table[:date].gteq(from.strftime('%F')).and(rank_table[:date].lteq(to.strftime('%F'))))
                           .where(rank_table[:hostname].eq(hostname))
                           .where(rank_table[:page_path].not_in(exclusion))
                           .select('*')
                           .select(rank_table[select_col].sum.as('accesses'))
                           .group(rank_table[:page_path])
                           .order('accesses DESC')
                           .paginate(page: params[:page], per_page: per_page)

  end
end
