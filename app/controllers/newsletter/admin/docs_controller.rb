# encoding: utf-8
class Newsletter::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Newsletter::MailHelper

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Newsletter::Content::Base.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    item = Newsletter::Doc.new
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'id DESC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Newsletter::Doc.new.find(params[:id])
    _show @item
  end

  def new
    @item = Newsletter::Doc.new({
      :state        => 'disabled',
    })
    if @content.template_state == 'enabled'
      @item.body = @content.template if @content.template
      @item.mobile_body = @content.template_mobile if @content.template_mobile
    end
  end

  def create
    @item = Newsletter::Doc.new(params[:item])
    @item.delivery_state = 'yet'
    @item.content_id = @content.id

    _create @item
  end

  def update
    @item = Newsletter::Doc.new.find(params[:id])
    @item.attributes = params[:item]

    _update(@item)
  end

  def destroy
    @item = Newsletter::Doc.new.find(params[:id])
    _destroy @item
  end

  def deliver
    @item = Newsletter::Doc.new.find(params[:id])
    _show @item
  end

  def test(item)
    if send_test_mail(item)
      flash[:notice] = 'テスト配信が完了しました。'
      respond_to do |format|
        format.html { redirect_to url_for(:action => :index) }
        format.xml  { head :ok }
      end
    end
  end

  def deliver_newsletter(item)
    @info = params[:info] || {}
    @info[:logs] = []

    if item.deliverable?
      if @info[:delivLogId].blank?
        # initialize
        item.delivery_state = 'delivering'
        item.delivered_at = Core.now
        item.save

        log_ids = []
        _letter_types = (@info[:letterType] == 'all') ? ['pc_text', 'mobile_text'] : [@info[:letterType]]
        _letter_types.each do |t|
          # mail
          mail_title = item.mail_title(t =~ /mobile/i)
          mail_body  = item.mail_body(t =~ /mobile/i)

          # member
          cnt = Newsletter::Member.count(:conditions => {:state => 'enabled',
                                    :content_id => item.content_id, :letter_type => t, :delivered_doc_id => item.id})
          Newsletter::Member.update_all("delivered_doc_id = null, delivered_at = null",
                                        {:content_id => item.content_id, :letter_type => t}) if cnt <= 0

          # log
          log_m = Newsletter::DeliveryLog.new.enabled
          log_m.and :content_id, @content.id
          log_m.and :letter_type, t
          log_m.and :doc_id, item.id
          log_m.order nil, 'id'

          log = log_m.find(:first)
          log ||= Newsletter::DeliveryLog.new({
            :state             => 'enabled',
            :content_id        => item.content_id,
            :doc_id            => item.id,
            :letter_type       => t,
            :delivery_state    => @info[:delivLogId].blank? ? 'delivering' : 'yet',
            :delivered_count   => '0',
            :deliverable_count => Newsletter::Member.count(:conditions => {:state => 'enabled',
                                    :content_id => item.content_id, :letter_type => t, :delivered_at => nil})
          })
          log.title = mail_title
          log.body  = mail_body
          log.save

          @info[:delivLogId] = log.id if @info[:delivLogId].blank?
          log_ids << log.id
          @info[:logs] << log
        end
        @info[:deliveryStatus] = item.delivery_state
        @info[:delivLogIds]    = log_ids.join(",")

      else
        # deliver
        log = Newsletter::DeliveryLog.new.find(@info[:delivLogId])

        mem = Newsletter::Member.new.enabled
        mem.and :content_id, @content.id
        mem.and :letter_type, log.letter_type
        mem.and :delivered_at, 'is', nil
        mem.and :created_at, '<', log.created_at
        mem.order nil, 'updated_at, id'
        mem.page  1, 30
        members = mem.find(:all)
        members.each do |m|
          # send mail
          send_newsletter_mail(item, [m])
          # update member
          m.delivered_doc_id = item.id
          m.delivered_at = Core.now
          m.save
          # update log
          log.delivery_state = 'delivering'
          log.delivered_count += 1
          log.last_member_id = m.id
          log.save
        end

        # exit?
        ids = @info[:delivLogIds].split(",")
        if members.length < 30
          # exit
          log.delivery_state = 'delivered'
          log.save
          if ids[ids.size-1] == @info[:delivLogId]
            # update doc
            item.delivery_state = 'delivered'
            item.delivered_at = Core.now
            item.save

            @info[:deliveryStatus] = 'delivered'
            @info[:logs] << Newsletter::DeliveryLog.new.find(ids[0]) if ids.size > 1
            @info[:logs] << log

          else
            # next letter type
            @info[:delivLogId] = ids[ids.size-1]
            next_log = Newsletter::DeliveryLog.new.find(ids[ids.size-1])
            next_log.delivery_state = 'delivering'
            next_log.save

            @info[:logs] << log
            @info[:logs] << next_log
          end # ids[ids.size-1] == @info[:delivLogId]
        else
          # next member
          @info[:logs] << log
          @info[:logs] << Newsletter::DeliveryLog.new.find(ids[ids.size-1])

        end # members.length < 30
      end # @info[:delivLogId].blank?
    else
      @info[:deliveryStatus] = 'delivered'
      @info[:logs] = item.logs
    end # item.deliverable?

    respond_to do |format|
      format.html { }
      format.js   { render :action => "deliver_result", :layout => false }
      format.xml  { }
    end
  end


protected
  def send_test_mail(item, users = nil)
    mail_fr = item.content.sender_address || item.creator.user.email

    users ||= item.tests
    users.each {|user| send_mail(mail_fr, user.email, item.mail_title(user.mobile?), item.mail_body(user.mobile?)) }
    return true
  end

  def send_newsletter_mail(item, users = nil)
    mail_fr = item.content.sender_address || item.creator.user.email

    users ||= item.members
    users.each {|user| send_mail(mail_fr, user.email, item.mail_title(user.mobile?), item.mail_body(user.mobile?)) }
    return true
  end
end
