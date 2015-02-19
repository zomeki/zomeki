module Cms::ApiGpCalendar
  extend ActiveSupport::Concern

  included do
  end

  def gp_calendar(path:, version:)
    case path.shift
    when 'sync_events'; gp_calendar_sync_events(path: path, version: version)
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

  def gp_calendar_sync_events_updated_events(version)
    case version
    when '20150201'
      content = GpCalendar::Content::Event.find_by_id(params[:content_id])
      return render(json: []) unless content.try(:public_node)

      events = content.public_events.reorder('updated_at DESC').limit((params[:limit] || 10).to_i)
      events.map! do |event|
        {id: event.id, updated_at: event.updated_at.to_s(:iso8601),
         title: event.title,
         started_on: event.started_on.to_s(:iso8601), ended_on: event.ended_on.to_s(:iso8601),
         url: "#{content.public_node.public_full_uri}#{event.started_on.strftime('%Y/%m/')}"}
      end

      render json: events
    else render_404
    end
  end

  def gp_calendar_sync_events_invoke(version)
    case version
    when '20150201'
      content_id = params[:content_id].to_i
      event_id = params[:event_id].to_i
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
                          sync_source_id: event_id}

            events = JSON.parse(res.body)
            events.each do |event|
              next unless event.kind_of?(Hash)
              closed_key = {} if closed_key[:sync_source_id] == event['id'].to_i

              key = {sync_source_host: source_host,
                     sync_source_content_id: content_id,
                     sync_source_id: event['id']}
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

  def gp_calendar_sync_events_export(event)
    return if event.new_record?

    version = '20150201'
    source_host = URI.parse(event.content.site.full_uri).host
    destination_hosts = event.content.event_sync_destination_hosts.split(',').each(&:strip!)

    destination_hosts.each do |host|
      begin
        conn = Faraday.new(url: "http://#{host}") do |builder|
            builder.adapter Faraday.default_adapter
          end
        token = JSON.parse(conn.get('/_api/authenticity_token', version: version).body)['authenticity_token']
        query = {version: version, content_id: event.content_id, event_id: event.id, source_host: source_host, authenticity_token: token}
        res = conn.post '/_api/gp_calendar/sync_events/invoke', query
        warn_log "#{__FILE__}:#{__LINE__} #{res.headers['status']}" unless res.success?
      rescue => e
        warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      end
    end
  end
end
