class GpArticle::Public::Node::ArchivesController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
    return http_error(404) unless validate_date
  end

  def index
    if @month
      started_at = Time.new(@year, @month, 1)
      ended_at = started_at.end_of_month
    else
      started_at = Time.new(@year, 1, 1)
      ended_at = started_at.end_of_year
    end

    docs = GpArticle::Doc.arel_table
    @docs = @content.public_docs.where(docs[:display_published_at].gteq(started_at)
                                       .and(docs[:display_published_at].lteq(ended_at)))
                                .order('display_published_at DESC, published_at DESC')

    if @docs.empty?
      warn_log 'No archived docs'
      http_error(404)
    end

    header_format = @month ? '%Y年%-m月' : '%Y年'
    @items = @docs.inject([]) do |result, doc|
        date = doc.display_published_at.strftime(header_format)

        unless result.empty?
          last_date = result.last[:doc].display_published_at.strftime(header_format)
          date = nil if date == last_date
        end

        result.push(date: date, doc: doc)
      end
  end

  private

  def validate_date
    @month = params[:month].to_i
    if @month.zero?
      @month = nil
    else
      return false unless @month.between?(1, 12)
    end

    @year = params[:year].to_i
    @year = Date.today.year if @year.zero?
    return false unless @year.between?(1900, 2100)

    return true
  end
end
