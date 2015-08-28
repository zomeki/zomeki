# encoding: utf-8
class GpArticle::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  include Cms::ApiGpCalendar
  include GpArticle::DocsCommon

  before_filter :hold_document, :only => [ :edit ]
  before_filter :check_intercepted, :only => [ :update ]

  def pre_dispatch
    return http_error(404) unless @content = GpArticle::Content::Doc.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset_criteria]

    @category_types = @content.category_types
    @visible_category_types = @content.visible_category_types
    @event_category_types = @content.event_category_types
    @marker_category_types = @content.marker_category_types

    @item = @content.docs.find(params[:id]) if params[:id].present?

    @params_categories = params[:categories].kind_of?(Hash) ? params[:categories] : {}
    @params_event_categories = params[:event_categories].kind_of?(Hash) ? params[:event_categories] : {}
    @params_marker_categories = params[:marker_categories].kind_of?(Hash) ? params[:marker_categories] : {}

    @params_item_in_editable_groups = if (ieg = params[:item].try('[]', :in_editable_groups)).kind_of?(Array)
                                        ieg
                                      end
    @params_item_in_maps = if (im = params[:item].try('[]', :in_maps)).kind_of?(Hash)
                             im
                           end
    @params_share_accounts = params[:share_accounts] if params[:share_accounts].kind_of?(Array)
  end

  def index
    if params[:options]
      @items = if params[:category_id]
                 if (category = GpCategory::Category.find_by_id(params[:category_id]))
                   params[:public] ? category.public_docs : category.docs
                 else
                   category.docs.none
                 end
               else
                 params[:public] ? @content.public_docs : @content.docs
               end

      if params[:exclude]
        docs_table = @items.table
        @items = @items.where(docs_table[:name].not_eq(params[:exclude]))
      end

      if params[:group_id] || params[:user_id]
        inners = []
        if params[:group_id]
            groups = Sys::Group.arel_table
            inners << :group
        end
        if params[:user_id]
            users = Sys::User.arel_table
            inners << :user
        end
        @items = @items.joins(:creator => inners)

        @items = @items.where(groups[:id].eq(params[:group_id])) if params[:group_id]
        @items = @items.where(users[:id].eq(params[:user_id])) if params[:user_id]
      end

      return render('index_options', layout: false)
    end

    criteria = params[:criteria] || {}

    case params[:target]
    when 'all'
      # No criteria
    when 'draft'
      criteria[:state] = 'draft'
      criteria[:touched_user_id] = Core.user.id
    when 'public'
      criteria[:state] = 'public'
      criteria[:touched_user_id] = Core.user.id
    when 'closed'
      criteria[:state] = 'closed'
      criteria[:touched_user_id] = Core.user.id
    when 'approvable'
      criteria[:approvable] = true
      criteria[:state] = 'approvable'
    when 'approved'
      criteria[:approvable] = true
      criteria[:state] = 'approved'
    else
      criteria[:editable] = true
    end
    criteria[:join_editor] = true

    docs = GpArticle::Doc.arel_table
    @items = GpArticle::Doc.all_with_content_and_criteria(@content, criteria).order(docs[:updated_at].desc).paginate(page: params[:page], per_page: 30)

    _index @items
  end

  def show
    _show @item
  end

  def new
    @item = @content.docs.build
    render 'new_smart_phone', layout: 'admin/gp_article_smart_phone' if Page.smart_phone?
  end

  def create
    failed_template = Page.smart_phone? ? {template: "#{controller_path}/new_smart_phone", layout: 'admin/gp_article_smart_phone'}
                                        : {action: 'new'}
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')

    @item = @content.docs.build(params[:item])

    @item.set_inquiry_group if Core.user.root?

    @item.validate_word_dictionary # replace validate word
    @item.ignore_accessibility_check = params[:ignore_accessibility_check]

    if Zomeki.config.application['cms.enable_accessibility_check']
      if params[:accessibility_check_modify] && params[:ignore_accessibility_check].nil?
        @item.body = Util::AccessibilityChecker.modify @item.body
      end
    end

    if params[:link_check_in_body] || (new_state == 'public' && params[:ignore_link_check].nil?)
      check_results = @item.check_links_in_body
      self.class.helpers.large_flash(flash, :key => :link_check_result,
                                     :value => render_to_string(partial: 'link_check_result', locals: {results: check_results}))
      return render(failed_template) if params[:link_check_in_body]
    end

    if Zomeki.config.application['cms.enable_accessibility_check']
      if params[:accessibility_check] || ((new_state == 'public' || new_state == 'approvable') && params[:ignore_accessibility_check].nil?)
        check_results = Util::AccessibilityChecker.check @item.body
        self.class.helpers.large_flash(flash, :key => :accessibility_check_result,
                                       :value => render_to_string(partial: 'accessibility_check_result', locals: {results: check_results}))
        return render(failed_template) if params[:accessibility_check]
      end
    end

    @item.state = new_state if new_state.present? && @item.class::STATE_OPTIONS.any?{|v| v.last == new_state }

    validate_approval_requests if @item.state_approvable?
    return render(failed_template) unless @item.errors.empty?

    location = ->(d){ edit_gp_article_doc_url(@content, d) } if @item.state_draft?
    _create(@item, location: location, failed_template: failed_template) do
      set_share_accounts
      set_categories
      set_event_categories
      set_marker_categories
      @item.fix_tmp_files(params[:_tmp])

      @item.approval_requests.each(&:reset) if @item.state_approvable?
      set_approval_requests
      @item = @content.docs.find_by_id(@item.id)
      @item.send_approval_request_mail if @item.state_approvable?

      publish_by_update(@item) if @item.state_public?

      share_to_sns(@item) if @item.state_public?
      publish_related_pages(@item) if @item.state_public?
      sync_events_export
    end
  end

  def edit
    return redirect_to(edit_gp_article_doc_url(@content, @item.duplicate(:replace))) if @item.state_public?
    render 'edit_smart_phone', layout: 'admin/gp_article_smart_phone' if Page.smart_phone?
  end

  def update
    failed_template = Page.smart_phone? ? {template: "#{controller_path}/edit_smart_phone", layout: 'admin/gp_article_smart_phone'}
                                        : {action: 'edit'}
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')

    @item.attributes = params[:item]
    @item.set_inquiry_group if Core.user.root?

    @item.validate_word_dictionary #replace validate word
    @item.ignore_accessibility_check = params[:ignore_accessibility_check]

    if Zomeki.config.application['cms.enable_accessibility_check']
      if params[:accessibility_check_modify] && params[:ignore_accessibility_check].nil?
        @item.body = Util::AccessibilityChecker.modify @item.body
      end
    end

    if params[:link_check_in_body] || (new_state == 'public' && params[:ignore_link_check].nil?)
      check_results = @item.check_links_in_body
      self.class.helpers.large_flash(flash, :key => :link_check_result,
                                     :value => render_to_string(partial: 'link_check_result', locals: {results: check_results}))
      return render(failed_template) if params[:link_check_in_body]
    end

    if Zomeki.config.application['cms.enable_accessibility_check']
      if params[:accessibility_check] || ((new_state == 'public' || new_state == 'approvable') && params[:ignore_accessibility_check].nil?)
        check_results = Util::AccessibilityChecker.check @item.body
        self.class.helpers.large_flash(flash, :key => :accessibility_check_result,
                                       :value => render_to_string(partial: 'accessibility_check_result', locals: {results: check_results}))
        return render(failed_template) if params[:accessibility_check]
      end
    end

    @item.state = new_state if new_state.present? && @item.class::STATE_OPTIONS.any?{|v| v.last == new_state }

    validate_approval_requests if @item.state_approvable?
    return render(failed_template) unless @item.errors.empty?

    location = url_for(action: 'edit') if @item.state_draft?
    _update(@item, location: location, failed_template: failed_template) do
      set_share_accounts
      set_categories
      set_event_categories
      set_marker_categories
      update_file_names

      @item.approval_requests.each(&:reset) if @item.state_approvable?
      set_approval_requests
      @item = @content.docs.find_by_id(@item.id)
      @item.send_approval_request_mail if @item.state_approvable?

      publish_by_update(@item) if @item.state_public?

      @item.close if !@item.public? && !@item.will_replace? # Never use "state_public?" here

      share_to_sns(@item) if @item.state_public?
      publish_related_pages(@item) if @item.state_public?
      sync_events_export

      release_document
    end
  end

  def destroy
    @old_category_ids = @item.categories.inject([]){|ids, category| ids | category.ancestors.map(&:id) }
    @new_category_ids = []
    _destroy(@item) do
      send_broken_link_notification(@item) if @content.notify_broken_link? && @item.backlinks.present?
      publish_related_pages(@item)
      sync_events_export
    end
  end

  def publish_ruby(item)
    uri = item.public_uri
    uri = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
    path = "#{item.public_path}.r"
    item.publish_page(render_public_as_string(uri, :site => item.content.site), :path => path, :dependent => :ruby)
  end

  def publish
    @old_category_ids = if @item.will_replace?
                          @item.prev_edition.categories.inject([]){|ids, category| ids | category.ancestors.map(&:id) }
                        else
                          []
                        end
    @new_category_ids = @item.categories.inject([]){|ids, category| ids | category.ancestors.map(&:id) }

    @item.update_attribute(:state, 'public')
    _publish(@item) do
      publish_ruby(@item)
      @item.rebuild(render_public_as_string(@item.public_uri, jpmobile: envs_to_request_as_smart_phone),
                    :path => @item.public_smart_phone_path, :dependent => :smart_phone)

      share_to_sns(@item)
      publish_related_pages(@item)
      sync_events_export
    end
  end

  def publish_by_update(item)
    return unless item.terminal_pc_or_smart_phone
    if item.publish(render_public_as_string(item.public_uri))
      publish_ruby(item)
      item.rebuild(render_public_as_string(item.public_uri, jpmobile: envs_to_request_as_smart_phone),
                   :path => item.public_smart_phone_path, :dependent => :smart_phone)
      flash[:notice] = '公開処理が完了しました。'
    else
      flash[:alert] = '公開処理に失敗しました。'
    end
  end

  def close(item)
    _close(@item) do
      @old_category_ids = @item.categories.inject([]){|ids, category| ids | category.ancestors.map(&:id) }
      @new_category_ids = []
      send_broken_link_notification(@item) if @content.notify_broken_link? && @item.backlinks.present?
      publish_related_pages(@item)
      sync_events_export
    end
  end

  def duplicate(item)
    if item.duplicate
      redirect_to url_for(:action => :index), notice: '複製処理が完了しました。'
    else
      redirect_to url_for(:action => :index), alert: '複製処理に失敗しました。'
    end
  end

  def approve
    @item.approve(Core.user, request) if @item.approvers.include?(Core.user)
    redirect_to url_for(:action => :show), notice: '承認処理が完了しました。'
  end

  def passback
    if @item.state_approvable? && @item.approvers.include?(Core.user)
      @item.passback(Core.user, comment: params[:comment])
      redirect_to gp_article_doc_url(@content, @item), notice: '差し戻しが完了しました。'
    else
      redirect_to gp_article_doc_url(@content, @item), notice: '差し戻しに失敗しました。'
    end
  end

  def pullback
    if @item.state_approvable? && @item.approval_requesters.include?(Core.user)
      @item.pullback(comment: params[:comment])
      redirect_to gp_article_doc_url(@content, @item), notice: '引き戻しが完了しました。'
    else
      redirect_to gp_article_doc_url(@content, @item), notice: '引き戻しに失敗しました。'
    end
  end

  protected

  def send_broken_link_notification(item)
    mail_from = 'noreply'

    item.backlinked_docs.each do |doc|
      subject = "【#{doc.content.site.name.presence || 'ZOMEKI'}】リンク切れ通知"

      body = <<-EOT
「#{doc.title}」からリンクしている「#{item.title}」が削除されました。
  対象のリンクは次の通りです。

#{item.backlinks.where(doc_id: doc.id).map{|l| "  ・#{l.body} ( #{l.url} )" }.join("\n")}

  次のURLをクリックしてリンクを確認してください。

  #{gp_article_doc_url(content: @content, id: doc.id)}
      EOT

      send_mail(mail_from, doc.creator.user.email, subject, body)
    end
  end

  def set_share_accounts
    share_account_ids = if params[:share_accounts].kind_of?(Array)
                          params[:share_accounts].map{|a| a.to_i if a.present? }.compact.uniq
                        else
                          []
                        end
    @item.sns_account_ids = share_account_ids
  end

  def set_categories
    @old_category_ids = @item.categories.inject([]){|ids, category| ids | category.ancestors.map(&:id) }

    category_ids = if params[:categories].is_a?(Hash)
                     params[:categories].values.flatten.map{|c| c.to_i if c.present? }.compact.uniq
                   else
                     []
                   end

    if @category_types.include?(@content.group_category_type)
      if (group_category = @content.group_category_type.categories.find_by_group_code(@item.creator.group.code))
        category_ids |= [group_category.id]
      end
    end

    if @content.default_category && @category_types.include?(@content.default_category_type)
      category_ids |= [@content.default_category.id]
    end

    @item.category_ids = category_ids

    @new_category_ids = @item.categories.inject([]){|ids, category| ids | category.ancestors.map(&:id) }
  end

  def set_event_categories
    event_category_ids = if params[:event_categories].is_a?(Hash)
                           params[:event_categories].values.flatten.map{|c| c.to_i if c.present? }.compact.uniq
                         else
                           []
                         end
    @item.event_category_ids = event_category_ids
  end

  def set_marker_categories
    marker_category_ids = if params[:marker_categories].is_a?(Hash)
                            params[:marker_categories].values.flatten.map{|c| c.to_i if c.present? }.compact.uniq
                          else
                            []
                          end
    @item.marker_category_ids = marker_category_ids
  end

  def hold_document
    unless (holds = @item.holds).empty?
      holds = holds.each{|h| h.destroy if h.user == Core.user }.reject(&:destroyed?)
      alerts = holds.map do |hold|
          in_editing_from = (hold.updated_at.today? ? I18n.l(hold.updated_at, :format => :short_ja) : I18n.l(hold.updated_at, :format => :default_ja))
          "#{hold.user.group.name}#{hold.user.name}さんが#{in_editing_from}から編集中です。"
        end
      flash[:alert] = "<ul><li>#{alerts.join('</li><li>')}</li></ul>".html_safe
    end
    @item.holds.create(user: Core.user)
  end

  def check_intercepted
    unless @item.holds.detect{|h| h.user == Core.user }
      user = @item.operation_logs.first.user
      flash[:alert] = "#{user.group.name}#{user.name}さんが記事を編集したため、編集内容を反映できません。"
      render :action => :edit
    end
  end

  def release_document
    @item.holds.destroy_all
  end

  def set_approval_requests
    approval_flow_ids = if params[:approval_flows].is_a?(Array)
                          params[:approval_flows].map{|a| a.to_i if a.present? }.compact.uniq
                        else
                          []
                        end

    approval_flow_ids.each do |approval_flow_id|
      request = @item.approval_requests.find_by_approval_flow_id(approval_flow_id)

      assignments = {}.with_indifferent_access
      if params.member?("assignment_ids_#{approval_flow_id}")
        if params["assignment_ids_#{approval_flow_id}"].is_a?(Hash)
          params["assignment_ids_#{approval_flow_id}"].each do |approval_id, value|
            assignments["approval_#{approval_id}"] = "#{value}"
          end
        end
      end

      unless request
        @item.approval_requests.create(user_id: Core.user.id, approval_flow_id: approval_flow_id)
        request = @item.approval_requests.find_by_approval_flow_id(approval_flow_id)
      end
      request.select_assignment = assignments
      request.user_id = Core.user.id
      request.save! if request.changed?
      request.reset
    end

    @item.approval_requests.each do |approval_request|
      approval_request.destroy unless approval_flow_ids.include?(approval_request.approval_flow_id)
    end
  end

  def validate_approval_requests
    approval_flow_ids = if params[:approval_flows].is_a?(Array)
                          params[:approval_flows].map{|a| a.to_i if a.present? }.compact.uniq
                        else
                          []
                        end

    if approval_flow_ids.empty?
      @item.errors.add(:base, '承認フローを選択してください。')
    else
      approval_flow_ids.each do |approval_flow_id|
        if params.member?("assignment_ids_#{approval_flow_id}") && params["assignment_ids_#{approval_flow_id}"].is_a?(Hash)
          if params["assignment_ids_#{approval_flow_id}"].is_a?(Hash)
            params["assignment_ids_#{approval_flow_id}"].each do |approval_id, value|
              @item.errors["承認者"] = "を選択してください。" if value.blank?
            end
          end
        end
      end
    end
  end

  def update_file_names
    if (file_names = params[:file_names]).kind_of?(Hash)
      new_body = @item.body
      file_names.each do |key, value|
        file = @item.files.where(id: key).first
        next if file.nil? || file.name == value
        new_body = new_body.gsub("file_contents/#{value}", "file_contents/#{file.name}")
      end
      @item.update_column(:body, new_body) unless @item.body == new_body
    end
  end

  def sync_events_export
    if @content.calendar_related? && (calendar_content = @content.gp_calendar_content_event)
      gp_calendar_sync_events_export(doc_or_event: @item, event_content: calendar_content) if calendar_content.event_sync_export?
    end
  end
end
