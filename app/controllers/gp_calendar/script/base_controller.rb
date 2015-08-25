class GpCalendar::Script::BaseController < Cms::Controller::Script::Publication
  private

  def publish_with_months
    min_date = 1.year.ago(Date.today.beginning_of_month)
    max_date = 2.years.since(min_date)

    prms = []
    date = min_date
    while (date < max_date)
      unless prms.include?(y = date.strftime('%Y/'))
        prms << y
      end
      prms << date.strftime('%Y/%m/')

      date = date.since(1.month).to_date
    end

    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s

    files = @node.content.public_categories.map{|c| "index_#{c.category_type.name}@#{c.path_from_root_category.gsub('/', '@')}" }

    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)
    files.each do |file|
      publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: "#{uri}#{file}", file: file)
    end
    prms.each do |prm|
      publish_more(@node, uri: "#{uri}#{prm}", path: "#{path}#{prm}", smart_phone_path: "#{smart_phone_path}#{prm}",
                          dependent: "#{uri}#{prm}")
      files.each do |file|
        publish_more(@node, uri: "#{uri}#{prm}", path: "#{path}#{prm}", smart_phone_path: "#{smart_phone_path}#{prm}",
                            dependent: "#{uri}#{prm}#{file}", file: file)
      end
    end

    events_table = GpCalendar::Event.arel_table
    events = @node.content.public_events.where(events_table[:started_on].lt(max_date)
                                               .and(events_table[:ended_on].gteq(min_date)))
    events.each(&:publish_files)
  end

  def publish_without_months
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s

    publish_more(@node, uri: uri, path: path, smart_phone_path: smart_phone_path, dependent: uri)
  end
end
