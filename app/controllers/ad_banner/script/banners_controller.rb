class AdBanner::Script::BannersController < Cms::Controller::Script::Publication
  def publish
    render text: 'OK'
  end
  
  def publish_by_task
    item = params[:item]
    if item && item.state == 'public'
      Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      item.publish_image

      info_log %Q!OK: Published to "#{item.image_path}"!
      params[:task].destroy
      Script.success
    end
    render text: 'OK'
  rescue => e
    error_log "#{__FILE__}:#{__LINE__} #{e.message}"
    render text: 'NG'
  end
  
  def close_by_task
    item = params[:item]
    if item && item.state == 'public'
      Script.current
      info_log "-- Close: #{item.class}##{item.id}"

      item.close_image

      info_log 'OK: Closed'
      params[:task].destroy
      Script.success
    end
    render text: 'OK'
  rescue => e
    error_log "#{__FILE__}:#{__LINE__} #{e.message}"
    render text: 'NG'
  end
end
