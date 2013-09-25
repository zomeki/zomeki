# encoding: utf-8
module Rank::Controller::Rank
  require 'rubygems'
  require 'garb'

  def get_access(content, start_date)

    if content.setting_value(:username).blank? ||
       content.setting_value(:password).blank? ||
       content.setting_value(:web_property_id).blank?
      flash[:alert] = "ユーザー・パスワード・トラッキングIDを設定してください。"
      return true
    end

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

      first_date = Date.today.strftime("%Y%m%d")
      results.each.with_index(1) do |result, i|
        rank = Rank::Rank.where(content_id: content.id)
                         .where(page_title: result.page_title)
                         .where(hostname:   result.hostname)
                         .where(page_path:  result.page_path)
                         .where(date:       result.date)
                         .first_or_create
        rank.pageviews = result.pageviews
        rank.visitors  = result.unique_pageviews
        rank.save!

        first_date = result.date if first_date > result.date
      end

      logger.info "Success: #{content.id}: #{content.setting_value(:username)}: #{content.setting_value(:web_property_id)}"
      flash[:notice] = "取り込みが完了しました。 （取り込み開始日は #{Date.parse(first_date).to_s} です）"
    rescue Garb::AuthenticationRequest::AuthError => e
      logger.warn "Error  : #{content.id}: #{content.setting_value(:username)}: #{content.setting_value(:web_property_id)}: #{e}"
      flash[:alert] = "認証エラーです。 （#{content.setting_value(:username)} ）"
      return false
    rescue => e
      logger.warn "Error  : #{content.id}: #{content.setting_value(:username)}: #{content.setting_value(:web_property_id)}: #{e}"
      flash[:alert] = "取り込みに失敗しました。"
      return false
    end

    return true
  end

  def get_data(profile, limit, offset, start_date)
    start_date = Date.new(start_date.year, start_date.month, start_date.day) unless start_date.nil?
    start_date = Date.new(2005,01,01) if start_date.blank? || start_date < Date.new(2005,01,01)

    res = Rank::GoogleAnalytics.results(profile, :limit => limit, :offset => offset, :start_date => start_date)
    return res
  end

end
