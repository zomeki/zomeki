# encoding: utf-8
class Sys::Admin::FrontController < Cms::Controller::Admin::Base
  def index
    item = Sys::Message.new.public
    @messages = item.find(:all, :order => 'published_at DESC')

    @maintenances = Core.site.maintenances.where(state: 'public')
                                          .order('published_at DESC')

    #@calendar = Util::Date::Calendar.new(nil, nil)
  end
end
