# encoding: utf-8
class GpCalendar::Public::Piece::MonthlyLinksController < GpCalendar::Public::Piece::BaseController
  def pre_dispatch
    @piece = GpCalendar::Piece::MonthlyLink.find_by_id(Page.current_piece.id)
    return render(:text => '') unless @piece

    @node = @piece.content.public_node
    return render(:text => '') unless @node

    date      = params[:gp_calendar_event_date]
    @min_date = params[:gp_calendar_event_min_date]
    @max_date = params[:gp_calendar_event_max_date]

    unless date
      date = Date.today
      @min_date = 1.year.ago(date.beginning_of_month)
      @max_date = 11.months.since(date.beginning_of_month)
    end

    @year     = date.year
    @month    = date.month

    return render(:text => '') unless @min_date

    @item = Page.current_item
  end

  def index
    @links = []
    year = nil
    date = @min_date
    while date <= @max_date
      month = date.month
      unless year == date.year
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
