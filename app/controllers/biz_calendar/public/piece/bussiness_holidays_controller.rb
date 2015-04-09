# encoding: utf-8
class BizCalendar::Public::Piece::BussinessHolidaysController < BizCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = BizCalendar::Piece::BussinessHoliday.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @item = Page.current_item
  end

  def index
    node = @piece.content.public_nodes.first
    return render(:text => '') unless node

    start_date = Date.today
    end_date   = (Date.today >> 12).end_of_month

    @start_date = start_date
    @end_date = end_date
    
    unless @piece.page_filter == 'through'
      if @item.class.to_s == "BizCalendar::Place"
        @place_name = @item.url
      end
    end

    unless @piece.target_next?
      @places = @piece.content.public_places
      @holidays           = Hash.new()
      @exception_holidays = Hash.new()
      @repeat_holidays    = Hash.new()

      @places.each do |place|
        @holidays[place.id] = Hash.new()
        holidays = []
        place.holidays.public.each do |h|
          if h.enable_holiday?(start_date, end_date)
            holidays << h
          end
        end

        holidays.each do |hh|
          n = hh.type ? hh.type.id : ''
          unless @holidays[place.id].member?(n)
            @holidays[place.id][n] = Hash.new()
            @holidays[place.id][n][:type] = hh.type ? hh.type : nil
            @holidays[place.id][n][:holidays] = []
          end
          @holidays[place.id][n][:holidays] << hh
        end
      end
      
    end

    @biz_calendar_node_uri = node.public_uri
  end
end
