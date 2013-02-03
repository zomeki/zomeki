# encoding: utf-8
class GpCalendar::Content::Event < Cms::Content
  default_scope where(model: 'GpCalendar::Event')
end
