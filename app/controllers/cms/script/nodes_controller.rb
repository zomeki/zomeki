class Cms::Script::NodesController < Cms::Controller::Script::Publication
  include Sys::Lib::File::Transfer

  def publish
    @transfer_to_publish = Zomeki.config.application['sys.transfer_to_publish']

    @ids = {}

    content_id = params[:target_content_id]

    case params[:target_module]
    when 'cms'
      if (target_node = Cms::Node.where(id: params[:target_node_id]).first)
        publish_node(target_node)
      end
    when 'gp_category'
      if content_id.present?
        GpCategory::Content::CategoryType.where(id: content_id).each do |content|
          publish_node(content.public_node) if content.try(:public_node)
        end
      else
        GpCategory::Content::CategoryType.all.each do |ct|
          publish_node(ct.public_node) if ct.public_node
        end
      end
    else
      Cms::Node.public.where(parent_id: 0).order('name, id').each do |node|
        publish_node(node)
      end
    end

    # file transfer
    transfer_files(:logging => true) if @transfer_to_publish

    render text: 'OK'
  end

  def publish_node(node)
    return if params[:all].nil? && node.model.in?('GpCategory::CategoryType')

    started_at = Time.now
    info_log "Publish node: #{node.model} #{node.name} #{node.title}"

    return if @ids.key?(node.id)
    @ids[node.id] = true

    return unless node.site

    unless node.public?
      node.close_page
      return
    end

    ## page
    if node.model == 'Cms::Page'
      begin
        uri = "#{node.public_uri}?node_id=#{node.id}"
        publish_page(node, uri: uri, site: node.site, path: node.public_path,
                                                      smart_phone_path: node.public_smart_phone_path)
      rescue Script::InterruptException => e
        raise e
      rescue => e
        Script.error "#{node.class}##{node.id} #{e}"
      end
      return
    end

    ## modules' page
    unless node.model == 'Cms::Directory'
      begin
        model = node.model.underscore.pluralize.gsub(/^(.*?)\//, '\1/script/')
        return unless "#{model.camelize}Controller".constantize.publishable?

        publish_page(node, uri: node.public_uri, site: node.site, path: node.public_path,
                                                      smart_phone_path: node.public_smart_phone_path)
        res = render_component_into_view :controller => model, :action => 'publish', :params => params.merge(node: node)

      rescue Script::InterruptException => e
        raise e
      rescue LoadError => e
        Script.error "#{node.class}##{node.id} #{e}"
        return
      rescue Exception => e
        Script.error "#{node.class}##{node.id} #{e}"
        return
      end
    end

    last_name = nil
    nodes = Cms::Node.arel_table
    Cms::Node.where(parent_id: node.id)
             .where(nodes[:name].not_eq(nil).and(nodes[:name].not_eq('')).and(nodes[:name].not_eq(last_name)))
             .order('directory, name, id').each do |child_node|
      last_name = child_node.name
      publish_node(child_node)
    end

    info_log "Published node: #{node.model} #{node.name} #{node.title} in #{(Time.now - started_at).round(2)} [secs.]"
  end

  def publish_by_task
    item = params[:item]
    if item.state == 'recognized' && item.model == 'Cms::Page'
      Script.current
      info_log "-- Publish: #{item.class}##{item.id}"
      item = Cms::Node::Page.find(item.id)
      uri  = "#{item.public_uri}?node_id=#{item.id}"
      path = "#{item.public_path}"

      unless item.publish(render_public_as_string(uri, site: item.site))
        raise item.errors.full_messages
      else
        Sys::OperationLog.script_log(:item => item, :site => item.site, :action => 'publish')
      end

      ruby_uri  = (uri =~ /\?/) ? uri.gsub(/(.*\.html)\?/, '\\1.r?') : "#{uri}.r"
      ruby_path = "#{path}.r"
      if item.published? || !::File.exist?(ruby_uri)
        item.publish_page(render_public_as_string(ruby_uri, :site => item.site),
          :path => ruby_path, :dependent => :ruby)
      end

      info_log %Q!OK: Published to "#{path}"!
      params[:task].destroy

      Script.success
    end
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: 'NG'
  end

  def close_by_task
    item = params[:item]
    if item.state == 'public' && item.model == 'Cms::Page'
      Script.current

      info_log "-- Close: #{item.class}##{item.id}"
      item = Cms::Node::Page.find(item.id)

      if item.close
        Sys::OperationLog.script_log(:item => item, :site => item.site, :action => 'close')
      end

      info_log 'OK: Closed'
      params[:task].destroy

      Script.success
    end
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: 'NG'
  end
end
