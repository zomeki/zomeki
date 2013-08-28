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

      require 'rubygems'
      require 'garb'

      Garb::Session.login(@content.setting_value(:username), @content.setting_value(:password))
      profile = Garb::Management::Profile.all.detect {|p| p.web_property_id == @content.setting_value(:web_property_id)}

      results = Rank::GoogleAnalytics.results(profile)

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
    end

    rank_table = Rank::Rank.arel_table
    select_col = 'pageviews' # 'visitors'
    from       = '0000-00-00'
    to         = '9999-99-99'
    @ranks = @content.ranks.where(rank_table[:date].gteq(from).and(rank_table[:date].lteq(to))).select('*').select(rank_table[select_col].sum.as('accesses')).group(rank_table[:page_path]).order('accesses DESC').paginate(page: params[:page], per_page: 50)

    _index @ranks
  end
end
