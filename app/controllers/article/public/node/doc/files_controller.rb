# encoding: utf-8
class Article::Public::Node::Doc::FilesController < Cms::Controller::Public::Base
  def show
    @content = Page.current_node.content
    
    doc = Article::Doc.new.public_or_preview
    if Core.mode == 'preview' && params[:doc_id]
      doc.and :id, params[:doc_id]
    end
    doc.and :content_id, @content.id
    doc.and :name, params[:name]
    doc.agent_filter(request.mobile)
    return http_error(404) unless @doc = doc.find(:first)
    
    item = Sys::File.new
    item.and :parent_unid, @doc.unid
    item.and :name, "#{params[:file]}.#{params[:format]}"
    return http_error(404) unless @file = item.find(:first)
    
    if img = @file.mobile_image(request.mobile, :path => @file.upload_path)
      return send_data(img.to_blob, :type => @file.mime_type, :filename => @file.name, :disposition => 'inline')
    end
    
    send_file @file.upload_path, :type => @file.mime_type, :filename => @file.name, :disposition => 'inline'
  end
end
