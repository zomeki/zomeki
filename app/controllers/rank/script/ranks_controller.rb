# encoding: utf-8

class Rank::Script::RanksController < ApplicationController
  include Rank::Controller::Rank

  def exec
    span = 3.days
    contents = Rank::Content::Rank.all
    contents.each do |content|
      get_access(content, Time.now - span)
      calc_access(content)
    end
    render(:text => "OK")
  end

end
