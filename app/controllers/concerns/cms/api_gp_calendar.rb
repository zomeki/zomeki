module Cms::ApiGpCalendar
  extend ActiveSupport::Concern

  included do
  end

  def gp_calendar(path:, version:)
    case path.shift
    when 'sync_events'; gp_calendar_sync_events(path: path, version: version)
    when 'sync_holidays'; gp_calendar_sync_holidays(path: path, version: version)
    else render_404
    end
  end

  def gp_calendar_sync_events(path:, version:)
    case path.shift
    when 'updated_events'
      if request.get?
        gp_calendar_sync_events_updated_events(version)
      else render_405
      end
    when 'invoke'
      if request.post?
        gp_calendar_sync_events_invoke(version)
      else render_405
      end
    else render_404
    end
  end

  def gp_calendar_sync_holidays(path:, version:)
    case path.shift
    when 'updated_holidays'
      if request.get?
        gp_calendar_sync_holidays_updated_holidays(version)
      else render_405
      end
    when 'invoke'
      if request.post?
        gp_calendar_sync_holidays_invoke(version)
      else render_405
      end
    else render_404
    end
  end

  def gp_calendar_sync_events_updated_events(version)
    case version
    when '20150201'
      content = GpCalendar::Content::Event.find_by_id(params[:content_id])
      return render(json: []) unless content.try(:public_node)

      limit = (params[:limit] || 10).to_i
      events = content.public_events.reorder('updated_at DESC').limit(limit)

      settings = GpArticle::Content::Setting.where(name: 'calendar_relation', value: 'enabled')
      contents = settings.map{|s|
                     next unless s.extra_values[:calendar_content_id] == content.id
                     next unless s.content.site == content.site
                     s.content
                   }.compact
      docs = contents.map{|c|
                 c.public_docs.where(event_state: 'visible').reorder('updated_at DESC').limit(limit)
               }.flatten
      docs.each do |doc|
        event = gp_calendar_doc_to_event(doc: doc, event_content: content)
        events << event if event
      end

      recent_events = events.sort{|a, b| (a.updated_at <=> b.updated_at) * -1 }[0, limit]
      recent_events.map! do |event|
        source_class = event.doc.class.name if event.doc
        source_class ||= event.class.name

        {id: event.id, updated_at: event.updated_at.to_s(:iso8601),
         title: event.title,
         started_on: event.started_on.to_s(:iso8601), ended_on: event.ended_on.to_s(:iso8601),
         url: event.href,
         source_class: source_class}
      end

      render json: recent_events
    else render_404
    end
  end

  def gp_calendar_sync_holidays_updated_holidays(version)
    case version
    when '20150201'
      content = GpCalendar::Content::Event.find_by_id(params[:content_id])
      return render(json: []) unless content.try(:public_node)

      limit = (params[:limit] || 10).to_i
      recent_holidays = content.public_holidays.reorder('updated_at DESC').limit(limit)
      recent_holidays.map! do |holiday|
        {id: holiday.id, updated_at: holiday.updated_at.to_s(:iso8601),
         title: holiday.title,
         date: holiday.date ? holiday.date.to_s(:iso8601) : holiday.date,
         repeat: holiday.repeat,
         description: holiday.description,
         kind: holiday.kind}
      end

      render json: recent_holidays
    else render_404
    end
  end

  def gp_calendar_sync_events_invoke(version)
    case version
    when '20150201'
      event_source_class = params[:event_source_class].to_s
      event_id = params[:event_id].to_i
      content_id = params[:content_id].to_i
      source_host = params[:source_host].to_s
      source_addr = Resolv.getaddress(source_host) rescue nil
      return render(json: {result: 'NG'}) if content_id.zero? || source_addr != request.remote_addr

      GpCalendar::Content::Event.find_each do |content|
        next unless content.event_sync_import?
        hosts = content.event_sync_source_hosts.split(',').each(&:strip!)
        next unless hosts.include?(source_host)

        begin
          conn = Faraday.new(url: "http://#{source_host}") do |builder|
              builder.adapter Faraday.default_adapter
            end
          query = {version: '20150201', content_id: content_id}
          res = conn.get '/_api/gp_calendar/sync_events/updated_events', query

          if res.success?
            closed_key = {sync_source_host: source_host,
                          sync_source_content_id: content_id,
                          sync_source_id: event_id,
                          sync_source_source_class: event_source_class}

            events = JSON.parse(res.body)
            events.each do |event|
              next unless event.kind_of?(Hash)
              key = {sync_source_host: source_host,
                     sync_source_content_id: content_id,
                     sync_source_id: event['id'].to_i,
                     sync_source_source_class: event['source_class'].to_s}

              closed_key = nil if closed_key == key

              attrs = {state: 'public',
                       title: event['title'],
                       started_on: event['started_on'],
                       ended_on: event['ended_on'],
                       href: event['url']}

              if (e = content.events.where(key).first)
                next unless e.updated_at < Time.parse(event['updated_at'])
                warn_log "#{__FILE__}:#{__LINE__} #{e.errors.inspect} #{event.inspect}" unless e.update_attributes(attrs)
              else
                e = content.events.build(key.merge attrs)
                e.in_creator = {group_id: content.creator.group_id, user_id: content.creator.user_id}
                warn_log "#{__FILE__}:#{__LINE__} #{e.errors.inspect} #{event.inspect}" unless e.save
              end
            end

            if closed_key.present? && (e = content.events.where(closed_key).first)
              e.close!
            end
          else
            warn_log "#{__FILE__}:#{__LINE__} #{res.headers['status']}"
          end
        rescue => e
          warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
        end
      end

      render json: {result: 'OK'}
    else render_404
    end
  end

  def gp_calendar_sync_holidays_invoke(version)
    case version
    when '20150201'
      holiday_id = params[:holiday_id].to_i
      content_id = params[:content_id].to_i
      source_host = params[:source_host].to_s
      source_addr = Resolv.getaddress(source_host) rescue nil
      return render(json: {result: 'NG'}) if content_id.zero? || source_addr != request.remote_addr

      GpCalendar::Content::Event.find_each do |content|
        next unless content.event_sync_import?
        hosts = content.event_sync_source_hosts.split(',').each(&:strip!)
        next unless hosts.include?(source_host)

        begin
          conn = Faraday.new(url: "http://#{source_host}") do |builder|
              builder.adapter Faraday.default_adapter
            end
          query = {version: '20150201', content_id: content_id}
          res = conn.get '/_api/gp_calendar/sync_holidays/updated_holidays', query

          if res.success?
            closed_key = {sync_source_host: source_host,
                          sync_source_content_id: content_id,
                          sync_source_id: holiday_id}

            holidays = JSON.parse(res.body)
            holidays.each do |holiday|
              next unless holiday.kind_of?(Hash)
              key = {sync_source_host: source_host,
                     sync_source_content_id: content_id,
                     sync_source_id: holiday['id'].to_i}

              closed_key = nil if closed_key == key

              attrs = {state: 'public',
                       title: holiday['title'],
                       date: holiday['date'],
                       repeat: holiday['repeat'],
                       description: holiday['description'],
                       kind: holiday['kind']}

              if (h = content.holidays.where(key).first)
                next unless h.updated_at < Time.parse(holiday['updated_at'])
                warn_log "#{__FILE__}:#{__LINE__} #{h.errors.inspect} #{holiday.inspect}" unless h.update_attributes(attrs)
              else
                h = content.holidays.build(key.merge attrs)
                h.in_creator = {group_id: content.creator.group_id, user_id: content.creator.user_id}
                warn_log "#{__FILE__}:#{__LINE__} #{h.errors.inspect} #{holiday.inspect}" unless h.save
              end
            end

            if closed_key.present? && (h = content.holidays.where(closed_key).first)
              h.close!
            end
          else
            warn_log "#{__FILE__}:#{__LINE__} #{res.headers['status']}"
          end
        rescue => e
          warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
        end
      end

      render json: {result: 'OK'}
    else render_404
    end
  end

  def gp_calendar_sync_events_export(doc_or_event:, event_content: nil)
    return unless doc_or_event.kind_of?(GpArticle::Doc) || doc_or_event.kind_of?(GpCalendar::Event)
    return if doc_or_event.kind_of?(GpArticle::Doc) && event_content.nil?
    return if doc_or_event.new_record?

    event = if doc_or_event.kind_of?(GpCalendar::Event)
              doc_or_event
            else
              gp_calendar_doc_to_event(doc: doc_or_event, event_content: event_content)
            end

    return unless event.kind_of?(GpCalendar::Event)

    version = '20150201'
    source_host = URI.parse(event.content.site.full_uri).host
    destination_hosts = event.content.event_sync_destination_hosts.split(',').each(&:strip!)

    destination_hosts.each do |host|
      begin
        conn = Faraday.new(url: "http://#{host}") do |builder|
            builder.request :url_encoded
            builder.adapter Faraday.default_adapter
          end
        token = JSON.parse(conn.get('/_api/authenticity_token', version: version).body)['authenticity_token']
        source_class = event.doc.class.name if event.doc
        source_class ||= event.class.name

        query = {version: version, authenticity_token: token,
                 source_host: source_host, content_id: event.content_id, event_id: event.id, event_source_class: source_class}
        res = conn.post '/_api/gp_calendar/sync_events/invoke', query
        warn_log "#{__FILE__}:#{__LINE__} #{res.headers['status']}" unless res.success?
      rescue => e
        warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      end
    end
  end

  def gp_calendar_sync_holidays_export(holiday:)
    return if holiday.new_record?

    version = '20150201'
    source_host = URI.parse(holiday.content.site.full_uri).host
    destination_hosts = holiday.content.event_sync_destination_hosts.split(',').each(&:strip!)

    destination_hosts.each do |host|
      begin
        conn = Faraday.new(url: "http://#{host}") do |builder|
            builder.request :url_encoded
            builder.adapter Faraday.default_adapter
          end
        token = JSON.parse(conn.get('/_api/authenticity_token', version: version).body)['authenticity_token']

        query = {version: version, authenticity_token: token,
                 source_host: source_host, content_id: holiday.content_id, holiday_id: holiday.id}
        res = conn.post '/_api/gp_calendar/sync_holidays/invoke', query
        warn_log "#{__FILE__}:#{__LINE__} #{res.headers['status']}" unless res.success?
      rescue => e
        warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      end
    end
  end

  def gp_calendar_doc_to_event(doc:, event_content:)
    return if (doc_id = doc.name.to_i).zero?
    event_started_on = doc.event_started_on
    event_started_on ||= doc.event_ended_on
    event_started_on ||= doc.display_published_at.try(:to_date)
    return if doc.event_started_on.blank?

    event_ended_on = doc.event_ended_on
    event_ended_on ||= event_started_on

    options = view_context.link_to_doc_options(doc)
    doc_uri = unless options.kind_of?(Array)
                doc.public_full_uri
              else
                if (uri = options[0].to_s)[0] == '/'
                  "#{doc.content.site.full_uri}#{uri[1..-1]}"
                else
                  uri
                end
              end

    event = GpCalendar::Event.new(title: doc.title, href: doc_uri, target: '_self',
                                  started_on: event_started_on, ended_on: event_ended_on,
                                  description: doc.summary, content_id: event_content.id)
    event.id = doc_id
    event.updated_at = doc.updated_at

    event.doc = doc

    event
  end
end
