class Cms::Script::NodesController < Cms::Controller::Script::Publication
  def publish
    @ids  = {}

    Cms::Node.public.where(parent_id: 0).order('name, id').each do |node|
      publish_node(node)
    end

    render text: 'OK'
  end

  def publish_node(node)
    return if @ids.key?(node.id)
    @ids[node.id] = true

    return unless node.site
    last_name = nil

    nodes = Cms::Node.arel_table
    Cms::Node.where(parent_id: node.id)
             .where(nodes[:name].not_eq(nil).and(nodes[:name].not_eq('')).and(nodes[:name].not_eq(last_name)))
             .order('directory, name, id').each do |child_node|
      last_name = child_node.name

      unless child_node.public?
        child_node.close_page
        next
      end

      ## page
      if child_node.model == 'Cms::Page'
        begin
          uri = "#{child_node.public_uri}?node_id=#{child_node.id}"
          publish_page(child_node, :uri => uri, :site => child_node.site, :path => child_node.public_path)
        rescue => e
          puts "Error: #{e}"
        end
        next
      end

      ## modules' page
      unless child_node.model == 'Cms::Directory'
        begin
          model = child_node.model.underscore.pluralize.gsub(/^(.*?)\//, '\1/script/')
          next unless "#{model.camelize}Controller".constantize.publishable?

          publish_page(child_node, :uri => child_node.public_uri, :site => child_node.site, :path => child_node.public_path)
          res = render_component_into_view :controller => model, :action => 'publish', :params => params.merge(node: child_node)
        rescue LoadError => e
          puts "Error: #{e}"
          next
        rescue Exception => e
          puts "Error: #{e}"
          next
        end
      end

      publish_node(child_node)
    end
  end

  def publish_by_task
    begin
      item = params[:item]
      if item.state == 'recognized' && item.model == 'Cms::Page'
        puts "-- Publish: #{item.class}##{item.id}"
        item = Cms::Node::Page.find(item.id)
        uri  = "#{item.public_uri}?node_id=#{item.id}"
        path = "#{item.public_path}"

        unless item.publish(render_public_as_string(uri, site: item.site))
          raise item.errors.full_messages
        end

        ruby_uri  = (uri =~ /\?/) ? uri.gsub(/(.*\.html)\?/, '\\1.r?') : "#{uri}.r"
        ruby_path = "#{path}.r"
        if item.published? || !::File.exist?(ruby_uri)
          item.publish_page(render_public_as_string(ruby_uri, :site => item.site),
            :path => ruby_path, :dependent => :ruby)
        end

        puts 'OK: Published'
        params[:task].destroy
      end
    rescue => e
      puts "Error: #{e}"
    end
    render text: 'OK'
  end

  def close_by_task
    begin
      item = params[:item]
      if item.state == 'public' && item.model == 'Cms::Page'
        puts "-- Close: #{item.class}##{item.id}"
        item = Cms::Node::Page.find(item.id)

        item.close

        puts 'OK: Closed'
        params[:task].destroy
      end
    rescue => e
      puts "Error: #{e}"
    end
    render text: 'OK'
  end
end
