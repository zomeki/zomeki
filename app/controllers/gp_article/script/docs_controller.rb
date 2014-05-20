class GpArticle::Script::DocsController < Cms::Controller::Script::Publication
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    publish_page(@node, :uri => "#{uri}index.rss", :path => "#{path}index.rss", :dependent => :rss)
    publish_page(@node, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)
    publish_more(@node, :uri => uri, :path => path, :first => 2)
    render text: 'OK'
  end

  def publish_by_task
    if (item = params[:item]).try(:state_approved?)
      info_log "-- Publish: #{item.class}##{item.id}"
      uri = item.public_uri.to_s
      path = item.public_path.to_s

      raise item.errors.full_messages unless item.publish(render_public_as_string(uri, :site => item.content.site))

      if item.published? || !::File.exist?("#{path}.r")
        item.publish_page(render_public_as_string("#{uri}index.html.r", :site => item.content.site),
                          :path => "#{path}.r", :dependent => :ruby)
      end

      info_log %Q!OK: Published to "#{path}"!
      params[:task].destroy
    end
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: 'NG'
  end

  def close_by_task
    if (item = params[:item]).try(:state_public?)
      info_log "-- Close: #{item.class}##{item.id}"

      item.close

      info_log 'OK: Closed'
      params[:task].destroy
    end
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: 'NG'
  end
end
