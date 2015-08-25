# encoding: utf-8
class Tool::Convert::PageInfo
  attr_accessor :file_path, :uri_path, :title, :body, :updated_at, :group_code, 
                :creator_group_id, :creator_user_id, 
                :inquiry_group_id, :inquiry_group_tel, :inquiry_group_fax, :inquiry_group_email,
                :category_ids, :category_name

  def uri
    URI.parse("http://#{@uri_path}") rescue nil
  end

  def kiji_page?
    @title.present? && @body.present?
  end

  def updated_from?(date)
    return true if @updated_at.blank? || date.blank?
    return Time.parse(date) < Time.parse(@updated_at)
  end

  def doc_filename_base
    File.basename(uri_path, '.*').to_s.gsub(/.htm$/, '').gsub('.', '_')
  end
end
