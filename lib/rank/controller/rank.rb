# encoding: utf-8
module Rank::Controller::Rank
  require 'rubygems'
  require 'garb'

  def get_access(content, start_date)

    if content.setting_value(:username).blank? ||
       content.setting_value(:password).blank? ||
       content.setting_value(:web_property_id).blank?
      flash[:alert] = "ユーザー・パスワード・トラッキングIDを設定してください。"
      return
    end

    begin
      Garb::Session.login(content.setting_value(:username), content.setting_value(:password))
      profile = Garb::Management::Profile.all.detect {|p| p.web_property_id == content.setting_value(:web_property_id)}

      limit = 1000
      results = google_analytics(profile, limit, nil, start_date)
      repeat_times = results.total_results / limit

      copy = results.to_a
      if(repeat_times != 0)
        repeat_times.times do |x|
          copy += google_analytics(profile, limit, (x+1)*limit + 1, start_date).to_a
        end
      end
      results = copy

      first_date = Date.today.strftime("%Y%m%d")
      ActiveRecord::Base.transaction do
        results.each_with_index do |result,i|
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
      end

      logger.info "Success: #{content.id}: #{content.setting_value(:username)}: #{content.setting_value(:web_property_id)}"
      flash[:notice] = "取り込みが完了しました。 （取り込み開始日は #{Date.parse(first_date).to_s} です）"
    rescue Garb::AuthenticationRequest::AuthError => e
      logger.warn "Error  : #{content.id}: #{content.setting_value(:username)}: #{content.setting_value(:web_property_id)}: #{e}"
      flash[:alert] = "認証エラーです。 （#{content.setting_value(:username)} ）"
    rescue => e
      logger.warn "Error  : #{content.id}: #{content.setting_value(:username)}: #{content.setting_value(:web_property_id)}: #{e}"
      flash[:alert] = "取り込みに失敗しました。"
    end
  end

  def calc_access(content)
    begin
      ActiveRecord::Base.transaction do
        Rank::Total.where(content_id: content.id).delete_all

        t = Date.today
        ranking_terms.each do |termname, term|
          case term
          when 'all'
            from = Date.new(2005, 1, 1)
            to   = t
          when 'previous_days'
            from = t.yesterday
            to   = t.yesterday
          when 'last_weeks'
            wday = t.wday == 0 ? 7 : t.wday
            from = t - (6 + wday).days
            to   = t - wday.days
          when 'last_months'
            from = (t - 1.month).beginning_of_month
            to   = (t - 1.month).end_of_month
          when 'this_weeks'
            from = t.yesterday - 7.days
            to   = t.yesterday
          end

          rank_table = Rank::Rank.arel_table
          Rank::Rank.select('*')
                    .select(rank_table[:pageviews].sum.as('pageviews'))
                    .select(rank_table[:visitors].sum.as('visitors'))
                    .where(content_id: content.id)
                    .where(rank_table[:date].gteq(from.strftime('%F')).and(rank_table[:date].lteq(to.strftime('%F'))))
                    .group(:hostname, :page_path)
                    .find_each do |result|

            Rank::Total.create!(content_id:  content.id,
                                term:        term,
                                page_title:  result.page_title,
                                hostname:    result.hostname,
                                page_path:   result.page_path,
                                pageviews:   result.pageviews,
                                visitors:    result.visitors)
          end
        end
      end

      ActiveRecord::Base.transaction do
        Rank::Category.where(content_id: content.id).delete_all

        category_ids = GpCategory::CategoryType.public.inject([]) do |ids, ct|
          ids.concat(ct.public_root_categories.inject([]) do |id, c|
            id.concat(c.public_descendants.map(&:id))
          end)
        end

        GpCategory::Category.public.each do |c|
          category_ids << c.public_descendants.map(&:id)
        end
        category_ids = category_ids.flatten.uniq

        docs = GpArticle::Doc.all_with_content_and_criteria(nil, category_id: category_ids).mobile(::Page.mobile?).public
        docs.each do |doc|
          doc.categories.each do |c|
            Rank::Category.where(content_id:  content.id)
                          .where(page_path:   doc.public_uri)
                          .where(category_id: c)
                          .first_or_create
          end
        end
      end

      logger.info "Makeup : #{content.id}"
      flash[:notice] = "集計が完了しました。"
    rescue => e
      logger.warn "Error  : #{content.id}: #{e}"
      flash[:alert] = "集計に失敗しました。"
    end
  end

  def rank_datas(content, term, target, per_page, category = nil)
    hostname   = URI.parse(Core.site.full_uri).host
    exclusion  = content.setting_value(:exclusion_url).strip.split(/[ |\t|\r|\n|\f]+/) rescue exclusion = ''
    rank_table = Rank::Total.arel_table

    ranks = Rank::Total.select('*')
                       .select(rank_table[target].as('accesses'))
                       .where(content_id: content.id)
                       .where(term:       term)
                       .where(hostname:   hostname)
                       .where(rank_table[:page_path].not_in(exclusion))

    if category == 'on'
      category_ids = []
      @item = Page.current_item
      case @item
        when GpCategory::CategoryType
          category_ids = @item.categories.map(&:id)
        when GpCategory::Category
          category_ids << @item.id
      end

      if category_ids.size > 0
        ranks = ranks.where(Rank::Category.select(:id)
                                          .where(content_id:  content.id)
                                          .where(page_path:   rank_table[:page_path])
                                          .where(category_id: category_ids).exists)
      end
    end

    ranks = ranks.order('accesses DESC').paginate(page: params[:page], per_page: per_page)
  end

  def ranking_targets
    return Rank::Rank::TARGETS
  end

  def ranking_terms
    return [['すべて', 'all']] + Rank::Rank::TERMS
  end

  def param_check(ary, str)
    str = ary.first[1] if str.blank? || !ary.flatten.include?(str)
    str
  end

private
  def google_analytics(profile, limit, offset, start_date)
    start_date = Date.new(start_date.year, start_date.month, start_date.day) unless start_date.nil?
    start_date = Date.new(2005,01,01) if start_date.blank? || start_date < Date.new(2005,01,01)

    Rank::GoogleAnalytics.results(profile, :limit => limit, :offset => offset, :start_date => start_date)
  end

end
