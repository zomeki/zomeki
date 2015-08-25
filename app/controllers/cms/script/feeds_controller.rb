# encoding: utf-8
class Cms::Script::FeedsController < ApplicationController
  include Cms::Controller::Layout

  def read
    success = 0
    error   = 0
    feeds = Cms::Feed.find(:all, :conditions => { :state => 'public' })
    #feeds = Cms::Feed.find(:all)
    Script.total feeds.size
    
    feeds.each do |feed|
      Script.current
      
      begin
        if feed.update_feed
          Script.success
          success += 1
        else
          raise "DestroyFailed : #{feed.uri}"
        end
      rescue Script::InterruptException => e
        raise e
      rescue => e
        Script.error e
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
