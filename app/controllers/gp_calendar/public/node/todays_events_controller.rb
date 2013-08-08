# encoding: utf-8
class GpCalendar::Public::Node::TodaysEventsController < GpCalendar::Public::Node::BaseController
  def index
    criteria = {date: @today}
    @events = GpCalendar::Event.public.all_with_content_and_criteria(@content, criteria).order(:started_on)

    merge_docs_into_events(event_docs(@today, @today), @events)

    if (category = find_category_by_specified_path(params[:category]))
      @events.reject! {|e| (e.category_ids & category.public_descendants.map(&:id)).empty? }
    end

    category_ids = @events.inject([]) {|i, e| i.concat(e.category_ids) }
    @event_categories = GpCategory::Category.where(id: category_ids)
  end
end
