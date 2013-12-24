# encoding: utf-8

class Tool::Convert::NormalKijiDbProcessor < Tool::Convert::DbProcessor

  def create_target
    target = GpArticle::Doc.new
    target.body =  @page_info.body
    target.title = @page_info.title
    target.state = @options[:state]
    target.content_id = @options[:content_id]
    target.in_creator = @options[:creator]
    target.ignore_accessibility_check = @options[:ignore_accessibility_check]
   
    if !target.save
      puts "upload_article_doc:アップロード失敗:#{file_path}"
      p target.errors.full_messages
      return nil
    else
      target.published_at = doc.created_at
      target.recognized_at = doc.created_at
      target.save
      return target
    end
  end

end
