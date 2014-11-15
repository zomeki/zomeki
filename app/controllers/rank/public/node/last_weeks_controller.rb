# encoding: utf-8
class Rank::Public::Node::LastWeeksController < Cms::Controller::Public::Base
  include Sys::Controller::Scaffold::Base
  include Rank::Controller::Rank

  def pre_dispatch
    @node = Page.current_node
    @content = Rank::Content::Rank.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @term   = 'last_weeks'
    @target = 'pageviews'
    @ranks  = rank_datas(@content, @term, @target, 20)

    return http_error(404) if @ranks.blank?

    _index @ranks
  end
end
