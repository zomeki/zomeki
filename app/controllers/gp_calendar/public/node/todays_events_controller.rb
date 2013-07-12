# encoding: utf-8
class GpCalendar::Public::Node::TodaysEventsController < Cms::Controller::Public::Base
  def pre_dispatch
    @node = Page.current_node
    @content = GpCalendar::Content::Event.find_by_id(@node.content.id)
    return http_error(404) unless @content
  end

  def index
    @today = Date.today
    criteria = {date: @today}
    @events = GpCalendar::Event.all_with_content_and_criteria(@content, criteria)
    if params[:category].present? &&
      (category = @content.categories.detect {|c| c.path_from_root_category == params[:category] })
      @events.select! {|e| e.category_ids.include?(category.id) }
    end
  end
end
