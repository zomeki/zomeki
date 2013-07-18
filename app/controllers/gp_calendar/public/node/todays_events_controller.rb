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
    @events = GpCalendar::Event.public.all_with_content_and_criteria(@content, criteria)
    if (category = find_category_by_specified_path(params[:category]))
      @events.select! {|e| e.category_ids.include?(category.id) }
    end
  end

  private

  def find_category_by_specified_path(path)
    return nil unless path.kind_of?(String)
    category_type_name, category_path = path.split('/', 2)
    category_type = @content.category_types.find_by_name(category_type_name)
    return nil unless category_type
    category_type.find_category_by_path_from_root_category(category_path)
  end
end
