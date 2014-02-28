# encoding: utf-8
class GpCalendar::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    GpCalendar::Content::Event
  end
end
