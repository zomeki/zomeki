# encoding: utf-8
class Newsletter::Public::Node::FormsController < Cms::Controller::Public::Base

  def pre_dispatch
    return http_error(404) unless content = Page.current_node.content
    @content = Newsletter::Content::Base.find_by_id(content.id)
  end

  def index
    if _receive
      # complete view
      redirect_to "#{Page.current_node.public_uri}sent/#{@item.id}/#{@item.token}/"
    else
      return false
    end
  end

  def change
    if _receive
      # complete view
      redirect_to "#{Page.current_node.public_uri}sent/#{@item.id}/#{@item.token}/"
    else
      return false
    end
  end

  def sent
    item = Newsletter::Request.new
    item.and :content_id, @content.id
    item.and :id, params[:id]
    item.and :token, params[:token]
    return http_error(404) unless @item = item.find(:first)

    if @item.subscribe? && !slave?
      @item.destroy
    end
  end

  def unsubscribe
    req = Newsletter::Request.new
    req.and :content_id, @content.id
    req.and :id, params[:id]
    req.and :token, params[:token]
    unless @req = req.find(:first)
      render :text => '既に解除されているか、登録されていない可能性があります。'
      return false
    end

    # member, request
    mem = Newsletter::Member.new.enabled
    mem.and :content_id, @content.id
    mem.and :email, @req.unsubscribe_email
    # mem.and :letter_type, @req.letter_type
    if slave?
      @req.request_state = 'done'
      @req.save
    else
      if @mem = mem.find(:first)
        @mem.state = 'disabled'
        @mem.save
      end
      @req.request_state = 'done'
      @req.destroy
    end

    # send mail
    send_notice_mail(@req)
    render :text => "メールマガジンの解除が完了いたしました。"
    return false
  end

protected
  def _receive
    @item = Newsletter::Request.new({
      :state        => 'enabled',
      :content_id   => @content.id,
    })
    @item.is_slave(slave?)

    ## post
    return false unless request.post?
    @item.submit_values(params[:item], params[:subscribe])

    ## validate
    return false unless @item.valid?

    ## save
    # request
    @item.token = generate_token
    @item.save
    # member
    if @item.subscribe? && !slave?
      Newsletter::Member.new({
        :state        => 'enabled',
        :content_id   => @content.id,
        :letter_type  => @item.letter_type,
        :email        => @item.subscribe_email,
      }).save
    end

    ## send mail
    # subscribe            >> complete mail
    # alter or unsubscribe >> notice mail
    send_notice_mail(@item)
  end

  def send_notice_mail(item, optioins={})
    mail_fr = item.content.sender_address || item.creator.user.email
    subject = "#{item.notice_title}"
    body = "#{item.notice_body}"

    send_mail(mail_fr, item.email, subject, body)
    return true
  end

  def generate_token
    _token = ''
    chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    while _token.size < 30
      _token += chars[rand(chars.size) - 1, 1]
    end
    return _token
  end

  def slave?
    Core.config.has_key?('master') ? true : false;
  end
end
