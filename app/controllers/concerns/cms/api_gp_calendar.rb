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
      if request.get?
        gp_calendar_sync_events_invoke(version)
      else render_405
      end
    else render_404
    end
  end

  def gp_calendar_sync_events_updated_events(version)
    case version
    when '20150201'
      content = GpCalendar::Content::Event.find_by_code(params[:content_code])
      return render(json: []) unless content.try(:public_node)

      events = content.public_events.reorder('updated_at DESC').limit((params[:limit] || 15).to_i)
      events.map! do |event|
        {title: event.title, started_on: event.started_on.to_s(:iso8601),
                               ended_on: event.ended_on.to_s(:iso8601),
                             updated_at: event.updated_at.to_s(:iso8601),
         url: "#{content.public_node.public_full_uri}#{event.started_on.strftime('%Y/%m/')}"}
      end

      render json: events
    else render_404
    end
  end

  def gp_calendar_sync_events_invoke(version)
    case version
    when '20150201'
      result = if params[:content_code].present?
                 'OK'
               else
                 'NG'
               end
      render json: {result: result, remote_addr: request.remote_addr,
                                    remote_names: Resolv.getnames(request.remote_addr)}
    else render_404
    end
  end
end
