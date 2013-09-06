# encoding: utf-8
module Rank::Controller::Rank

  def get_access(content, start_date)

    return true if content.setting_value(:username).blank? or
                   content.setting_value(:password).blank? or
                   content.setting_value(:web_property_id).blank?

    begin
      require 'rubygems'
      require 'garb'

      Garb::Session.login(content.setting_value(:username), content.setting_value(:password))
      profile = Garb::Management::Profile.all.detect {|p| p.web_property_id == content.setting_value(:web_property_id)}

      start_date = Date.new(start_date.year, start_date.month, start_date.day)

      results = Rank::GoogleAnalytics.results(profile, :start_date => start_date)
      results.each do |result|
        rank = Rank::Rank.where(content_id: content.id)
                         .where(page_title: result.page_title)
                         .where(hostname:   result.hostname)
                         .where(page_path:  result.page_path)
                         .where(date:       result.date)
                         .first_or_create
        rank.pageviews = result.pageviews
        rank.visitors  = result.visitors
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

end
