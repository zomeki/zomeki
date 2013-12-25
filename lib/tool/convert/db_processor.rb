# encoding: utf-8

class Tool::Convert::DbProcessor

  attr_reader :target

  ### params
  #   options: {
  #     content_id: 1,
  #     creator: {group_id: 1, user_id: 1}
  #     state: "public",
  #     ignore_accessibility_check: true
  #   }
  def initialize(page_info, options={})
    @page_info = page_info
    @options = {
      content_id: 1,
      creator: {group_id: 1, user_id: 1},
      state: "public",
      ignore_accessibility_check: true
    }.merge options
  end

  def process
    @target = create_target
    create_convert_doc if @target
  end

  def create_target
    # TO inherited by sub class
    nil
  end

  def create_convert_doc
    cdoc = Tool::ConvertDoc.new
    cdoc.name = @target.name
    cdoc.doc_class = @target.class.to_s

    cdoc.uri_path = @page_info.uri_path
    cdoc.file_path = @page_info.file_path
    cdoc.host = @page_info.host

    cdoc.title = @page_info.title
    cdoc.body = @page_info.body
    cdoc.published_at = @target.published_at

    if !cdoc.save
      puts "upload_convertdoc:アップロード失敗:#{file_path}"
      p cdoc.errors.full_messages
      nil
    else
      cdoc
    end
  end

  def target_name
    @target.nil? ? "" : @target.name
  end

end
