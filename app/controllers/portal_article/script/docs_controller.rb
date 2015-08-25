# encoding: utf-8
class PortalArticle::Script::DocsController < Cms::Controller::Script::Publication
  def publish
    return render(:text => "OK")
    
    uri  = "#{@node.public_uri}"
    path = "#{@node.public_path}"
    publish_more(@node, :uri => uri, :path => path, :first => 2)
    return render(:text => "OK")
  end
  
  def publish_by_task
    begin
      item = params[:item]
      if item.state == 'recognized'
        Script.current
        puts "-- Publish: #{item.class}##{item.id}"
        uri  = "#{item.public_uri}?doc_id=#{item.id}"
        path = "#{item.public_path}"
        
        if !item.publish(render_public_as_string(uri, :site => item.content.site))
          raise item.errors.full_messages
        else
          Sys::OperationLog.script_log(:item => item, :site => item.content.site, :action => 'publish')
        end
        if item.published? || !::File.exist?("#{path}.r")
          item.publish_page(render_public_as_string("#{uri}index.html.r", :site => item.content.site),
            :path => "#{path}.r", :dependent => :ruby)
        end
        
        puts "OK: Published"
        params[:task].destroy
        Script.success
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
        Script.current
        puts "-- Close: #{item.class}##{item.id}"
        
        if item.close
          Sys::OperationLog.script_log(:item => item, :site => item.content.site, :action => 'close')
        end
        
        puts "OK: Closed"
        params[:task].destroy
        Script.success
      end
    rescue => e
      puts "Error: #{e}"
    end
    return render(:text => "OK")
  end
end
