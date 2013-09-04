# encoding: utf-8
class Rank::Admin::RanksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Rank::Content::Rank.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
  end

  def index

    if @content.ranks.empty? and
       @content.setting_value(:username).present? and
       @content.setting_value(:password).present? and
       @content.setting_value(:web_property_id).present?

      begin
        require 'rubygems'
        require 'garb'

        Garb::Session.login(@content.setting_value(:username), @content.setting_value(:password))
        profile = Garb::Management::Profile.all.detect {|p| p.web_property_id == @content.setting_value(:web_property_id)}

        results = Rank::GoogleAnalytics.results(profile, :start_date => DateTime.parse(@content.setting_value(:start_date)) || Time.now - 1.month)

        results.each do |result|
          Rank::Rank.create!(
              :content_id => @content.id,
              :page_title => result.page_title,
              :hostname   => result.hostname,
              :page_path  => result.page_path,
              :date       => result.date,
              :pageviews  => result.pageviews,
              :visitors   => result.visitors,
              )
        end
      rescue Garb::AuthenticationRequest::AuthError => e
        logger.warn e
        flash[:alert] = "認証エラーです。 （#{@content.setting_value(:username)} ）"
      rescue => e
        logger.warn e
      end
    end

    rank_table = Rank::Rank.arel_table
    @target = params[:target]
    @target = 'pageviews' unless @target == 'pageviews' || @target == 'visitors'
    from    = params[:from].blank? ? '0000-00-00' : params[:from]
    to      = params[:to].blank?   ? '9999-99-99' : params[:to]
    @ranks  = @content.ranks.where(rank_table[:date].gteq(from).and(rank_table[:date].lteq(to))).select('*').select(rank_table[@target].sum.as('accesses')).group(rank_table[:page_path]).order('accesses DESC').paginate(page: params[:page], per_page: 50)

    _index @ranks
  end

  after_filter :flash_clear
  def flash_clear
    flash[:alert ] = nil
    flash[:notice] = nil
  end
end