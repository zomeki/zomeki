# encoding: utf-8
class Cms::Script::FeedsController < ApplicationController
  include Cms::Controller::Layout

  def read
    success = 0
    error   = 0
    feeds = Cms::Feed.find(:all, :conditions => { :state => 'public' })
    #feeds = Cms::Feed.find(:all)
    feeds.each do |feed|
      begin
        if feed.update_feed
          success += 1
        else
          raise 'DestroyFailed'
        end
      rescue => e
        error += 1
      end
    end

    if error > 0
      puts "Finished. Success: #{success}, Error: #{error}"
      render :text => "NG"
    else
      puts "Finished. Success: #{success}"
      render :text => "OK"
    end
  end
end
