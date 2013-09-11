# encoding: utf-8
module Rank::Controller::Rank
  require 'rubygems'
  require 'garb'

  def get_access(content, start_date)

    return true if content.setting_value(:username).blank? or
                   content.setting_value(:password).blank? or
                   content.setting_value(:web_property_id).blank?

    begin
      Garb::Session.login(content.setting_value(:username), content.setting_value(:password))
      profile = Garb::Management::Profile.all.detect {|p| p.web_property_id == content.setting_value(:web_property_id)}

      limit = 1000
      results = get_data(profile, limit, nil, start_date)
      repeat_times = results.total_results / limit

      copy = results.to_a
      if(repeat_times != 0)
        repeat_times.times do |x|
          copy += get_data(profile, limit, (x+1)*limit + 1, start_date).to_a
        end
      end
      results = copy

      results.each.with_index(1) do |result, i|
        rank = Rank::Rank.where(content_id: content.id)
                         .where(page_title: result.page_title)
                         .where(hostname:   result.hostname)
                         .where(page_path:  result.page_path)
                         .where(date:       result.date)
                         .first_or_create
        rank.pageviews = result.pageviews
        rank.visitors  = result.visits
        rank.save!
      end

      logger.info "Success: #{content.id}: #{content.setting_value(:username)}: #{content.setting_value(:web_property_id)}"
    rescue Garb::AuthenticationRequest::AuthError => e
      logger.warn "Error  : #{content.id}: #{content.setting_value(:username)}: #{content.setting_value(:web_property_id)}: #{e}"
      flash[:alert] = "認証エラーです。 （#{content.setting_value(:username)} ）"
      return false
    rescue => e
      logger.warn "Error  : #{content.id}: #{content.setting_value(:username)}: #{content.setting_value(:web_property_id)}: #{e}"
      return false
    end

    return true
  end

  def get_data(profile, limit, offset, start_date)
    start_date = Date.new(start_date.year, start_date.month, start_date.day) unless start_date.nil?
    res = Rank::GoogleAnalytics.results(profile, :limit => limit, :offset => offset, :start_date => start_date)
    return res
  end

end
