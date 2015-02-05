require 'httpclient'

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
      source_host = params[:source_host].to_s
      source_addr = Resolv.getaddress(source_host) rescue nil
      return render(json: {result: 'NG'}) if content_id.zero? || source_addr != request.remote_addr

      GpCalendar::Content::Event.find_each do |content|
        next unless content.event_sync_import?
        hosts = content.event_sync_source_hosts.split(',').each(&:strip!)
        next unless hosts.include?(source_host)

        begin
          client = HTTPClient.new
          query = {version: '20150201', content_id: content_id}
          url = "http://#{source_host}/_api/gp_calendar/sync_events/updated_events"

          res = client.get(url, query)
          if res.ok?
            events = JSON.parse(res.content)
            events.each do |event|
              next unless event.kind_of?(Hash)
              key = {sync_source_host: source_host,
                     sync_source_content_id: content_id,
                     sync_source_id: event['id']}
              attrs = {title: event['title'],
                       started_on: event['started_on'],
                       ended_on: event['ended_on'],
                       href: event['url']}
              e = content.events.where(key).first
              if e
                next unless e.updated_at < Time.parse(event['updated_at'])
                warn_log "#{__FILE__}:#{__LINE__} #{e.errors.inspect} #{event.inspect}" unless e.update_attributes(attrs)
              else
                e = content.events.build(key.merge attrs)
                e.in_creator = {group_id: content.creator.group_id, user_id: content.creator.user_id}
                warn_log "#{__FILE__}:#{__LINE__} #{e.errors.inspect} #{event.inspect}" unless e.save
              end
            end
          else
            warn_log "#{__FILE__}:#{__LINE__} #{res.status} #{res.reason}"
          end
        rescue => e
          warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
        end
      end

      render json: {result: 'OK'}
    else render_404
    end
  end
end
