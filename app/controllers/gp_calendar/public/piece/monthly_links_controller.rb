# encoding: utf-8
class GpCalendar::Public::Piece::MonthlyLinksController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCalendar::Piece::MonthlyLink.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @node = @piece.content.event_node
    return render(:text => '') unless @node

    @year     = params[:gp_calendar_event_year]
    @month    = params[:gp_calendar_event_month]
    @min_date = params[:gp_calendar_event_min_date]
    @max_date = params[:gp_calendar_event_max_date]
    return render(:text => '') unless @min_date

    @item = Page.current_item
  end

  def index
    @links = []
    year = nil
    date = @min_date
    while date <= @max_date
      month = date.month
      if year != date.year
        year = date.year
        css_class = "year year#{year}"
        css_class.concat(' current') if @year == date.year && @month.nil?
        @links << {
            :name   => date.strftime('%Y年'),
            :uri    => "#{@node.public_uri}#{year}/",
            :class  => css_class,
            :months => []
          }
      end
      css_class = "month month#{month}"
      css_class.concat(' current') if @year == date.year && @month == month
      @links.last[:months] << {
          :name  => date.strftime('%-m月'),
          :uri   => "#{@node.public_uri}#{year}/%02d/" % month,
          :class => css_class
        }
      date = date >> 1
    end
  end
end
