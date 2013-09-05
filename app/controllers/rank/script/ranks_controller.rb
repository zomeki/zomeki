# encoding: utf-8

class Rank::Script::RanksController < ApplicationController
  include Rank::Controller::Rank

  def exec
    span = 3.days
    contents = Rank::Content::Rank.all
    contents.each do |content|
      start_date = DateTime.parse(content.setting_value(:start_date)) rescue Time.now - span
      start_date = Time.now - span if start_date < Time.now - span

      get_access(content, start_date)
    end
    render(:text => "OK")
  end

end
