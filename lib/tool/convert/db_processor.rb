# encoding: utf-8
class Tool::Convert::DbProcessor
  PROCESS_TYPES = [['作成', 'created'], ['更新', 'updated'], ['非更新', 'nonupdated']]
  attr_reader :doc, :cdoc, :process_type

  def process_type_label
    PROCESS_TYPES.rassoc(@process_type).try(:first)
  end

  def process(page, conf)
    # 更新チェック
    if @cdoc = Tool::ConvertDoc.where(uri_path: page.uri_path).first
      if @doc = @cdoc.latest_doc
        if conf.overwrite == 0 && !page.updated_from?(@cdoc.page_updated_at)
          @process_type = 'nonupdated'
          return self
        else
          @process_type = 'updated'
        end
      else
        @doc = conf.content.model.constantize.new(content_id: conf.content_id)
        @process_type = 'created'
      end
    else
      @cdoc = Tool::ConvertDoc.new
      @doc = conf.content.model.constantize.new(content_id: conf.content_id)
      @process_type = 'created'
    end

    dump @process_type

    @doc.state ||= conf.doc_state
    @doc.filename_base = page.doc_filename_base if @doc.new_record? && conf.keep_filename == 1
    @doc.content_id = conf.content.id if conf.content
    @doc.concept_id = conf.content.concept_id if conf.content
    @doc.ignore_accessibility_check = conf.ignore_accessibility_check
    @doc.title = page.title
    @doc.body = page.body
    @doc.in_creator = { 'group_id' => page.creator_group_id, 'user_id' => page.creator_user_id }
    @doc.created_at ||= page.updated_at || Time.now
    @doc.updated_at ||= page.updated_at || Time.now
    @doc.published_at = page.updated_at || Time.now
    @doc.display_published_at = page.updated_at || Time.now
    @doc.display_updated_at   = page.updated_at || Time.now
    @doc.recognized_at      = page.updated_at || Time.now
    @doc.href ||= ''
    @doc.subtitle ||= ''
    @doc.summary ||= ''
    @doc.mobile_title ||= ''
    @doc.mobile_body ||= ''

    if @doc.inquiries.blank? && page.inquiry_group_id.present?
      @doc.inquiries.build(
        state: 'visible',
        group_id: page.inquiry_group_id,
        tel: page.inquiry_group_tel,
        fax: page.inquiry_group_fax,
        email: page.inquiry_group_email
      )
    end

    if @doc.save
      if @doc.category_ids.blank? && page.category_name.present? && @doc.content_id.present?
        if @doc.content.visible_category_types.present? &&
          cates = GpCategory::Category.where(category_type_id: @doc.content.visible_category_types.map(&:id))
                    .where(title: page.category_name)
          page.category_ids = page.category_ids.present? ? page.category_ids+cates.map(&:id) : cates.map(&:id)
          dump "設定カテゴリ：#{cates.map(&:title).join(', ')}"
        end
      end

      if @doc.category_ids.blank? && page.category_ids.present?
        @doc.category_ids = page.category_ids
      end
    else
      dump "記事保存失敗"
      dump @doc.errors.full_messages
      @process_type = 'error'
      return self
    end

    @cdoc.content = @doc.content
    @cdoc.docable = @doc
    @cdoc.doc_name = @doc.name
    @cdoc.doc_public_uri = @doc.public_uri
    @cdoc.published_at = @doc.published_at
    @cdoc.site_url = conf.site_url
    @cdoc.uri_path = page.uri_path
    @cdoc.file_path = page.file_path
    @cdoc.title = page.title
    @cdoc.body = page.body
    @cdoc.page_updated_at = page.updated_at
    @cdoc.page_group_code = page.group_code
    @cdoc.updated_at = Time.now

    unless @cdoc.save
      dump "変換記事保存失敗"
      dump @cdoc.errors.full_messages
      @process_type = 'error'
      return self
    end

    return self
  end
end
