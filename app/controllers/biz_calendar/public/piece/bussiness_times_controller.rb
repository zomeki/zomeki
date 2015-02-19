# encoding: utf-8
class BizCalendar::Public::Piece::BussinessTimesController < BizCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = BizCalendar::Piece::BussinessTime.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    node = @piece.content.public_nodes.first
    return render(:text => '') unless node

    unless @piece.page_filter == 'through'
      if @item.class.to_s == "BizCalendar::Place"
        @place_name = @item.url
      end
    end

    @biz_calendar_node_uri = node.public_uri
  end
end
