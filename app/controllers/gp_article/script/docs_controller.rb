class GpArticle::Script::DocsController < Cms::Controller::Script::Publication
  def publish
    uri  = "#{@node.public_uri}"
    path = "#{@node.public_path}"
    publish_more(@node, :uri => uri, :path => path, :first => 2)
    return render(:text => "OK")
  end
  
  def publish_by_task
    begin
      item = params[:item]
      if item.state == 'recognized'
        puts "-- Publish: #{item.class}##{item.id}"
        uri  = "#{item.public_uri}?doc_id=#{item.id}"
        path = "#{item.public_path}"
        
        if !item.publish(render_public_as_string(uri, :site => item.content.site))
          raise item.errors.full_messages
        end
        if item.published? || !::File.exist?("#{path}.r")
          item.publish_page(render_public_as_string("#{uri}index.html.r", :site => item.content.site),
            :path => "#{path}.r", :dependent => :ruby)
        end
        
        puts "OK: Published"
        params[:task].destroy
      end
    rescue => e
      puts "Error: #{e}"
    end
    return render(:text => "OK")
  end
  
  def close_by_task
    begin
      item = params[:item]
      if item.state == 'public'
        puts "-- Close: #{item.class}##{item.id}"
        
        item.close
        
        puts "OK: Closed"
        params[:task].destroy
      end
    rescue => e
      puts "Error: #{e}"
    end
    return render(:text => "OK")
  end
end
