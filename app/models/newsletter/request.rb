# encoding: utf-8
class Newsletter::Request < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept
  include Newsletter::Model::Base::Letter

  belongs_to :status,      :foreign_key => :state,        :class_name => 'Sys::Base::Status'
  belongs_to :content,     :foreign_key => :content_id,   :class_name => 'Newsletter::Content::Base'

  validate :validate_base
  
  def validate_base
    _email = email

    # required
    errors.add_to_base "メールアドレス を入力してください。" if _email.blank?
    errors.add_to_base "メールタイプ を選択してください。" if letter_type.blank? && subscribe?

    # format
    if !_email.blank?
      unless _email =~ /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+-+)|([A-Za-z0-9]+.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+-+)|(\w+.))*\w{1,63}.[a-zA-Z]{2,6}$/ix
        errors.add_to_base "メールアドレス が正しくありません。"
      end
    end

    # exist
    if errors.size == 0
      mems = Newsletter::Member.find(:all, :conditions => {:state => 'enabled', :content_id => content_id, :email => _email })
      if subscribe?
        _exist_flg = mems.length > 0
        if is_slave
          # request check
          reqs = self.class.find(:all, :conditions => {:state => 'enabled', :content_id => content_id,
                                 :request_state => 'done', :request_type => 'subscribe', :subscribe_email => _email })
          _exist_flg = true if reqs.length > 0
        end
        errors.add_to_base "既に登録されています。" if _exist_flg
      else
        # unsubscribe
        reqs = self.class.find(:all, :conditions => {:state => 'enabled', :content_id => content_id,
                               :request_state => 'done', :request_type => 'subscribe', :subscribe_email => _email })
        errors.add_to_base "入力されたメールアドレス は登録されていません。" if mems.length <= 0 && reqs.length <=0
      end
    end
  end

  def submit_values(item, is_subscribe=true, options={})
    self.attributes = item

    if is_subscribe
      self.request_state     = 'done'       # receive or done
      self.request_type      = 'subscribe'
      self.subscribe_email   = item[:subscribe_email] ||= item[:unsubscribe_email]
      self.unsubscribe_email = nil
    else
      self.request_state     = 'receive'    # receive or done
      self.request_type      = 'unsubscribe'
      self.subscribe_email   = nil
      self.unsubscribe_email = item[:subscribe_email] ||= item[:unsubscribe_email]
    end
  end

  def is_slave(slave=false)
    return @is_slave if @is_slave
    return @is_slave = slave
  end

  def subscribe?
    request_type == 'subscribe'
  end

  def request_done?
    request_state == 'done'
  end

  def unsubscribe_uri
    return nil unless id && token
    "#{::Page.current_node.public_full_uri}unsubscribe/#{id}/#{token}/"
  end

  def email
    subscribe? ? subscribe_email : unsubscribe_email
  end

  def notice_title
    _notice_title = ''
    _notice_title += "#{content.name} "
    _notice_title += subscribe? ? "登録完了のお知らせ" :
                     !request_done? ? "解除手続きのお知らせ" : "解除完了のお知らせ"
    _notice_title
  end

  def notice_body
    _notice_body = ''
    _notice_body += subscribe? ? subscribe_notice_body :
                    !request_done? ? unsubscribe_notice_body : unsubscribe_complete_body
    return _notice_body
  end

  def subscribe_notice_body
    _line = '-' * (mobile? ? 15 : 50)

    _body = ''
    _body += "この度は、#{content.name} にご登録いただきありがとうございます。\n"
    _body += "\n"
    _body += "ご登録いただいた内容は下記のとおりです。\n"
    _body += "#{_line}\n"
    _body += "■メールアドレス\n"
    _body += "　#{subscribe_email}\n"
    _body += "\n"
    _body += "■メールタイプ\n"
    _body += "　#{letter_type_name}\n"
    _body += "#{_line}\n"
    _body += "次回より、#{content.name} を配信いたします。\n"
    _body += "\n"
    _body += "\n"
    _body += "※メールマガジンの登録をした覚えがない方は、\n"
    _body += "第三者に無断で登録された可能性があります。\n"
    _body += "お手数をおかけしますが、下記のページから\n"
    _body += "解除手続きを行ってください。\n"
    _body += "\n"
    _body += "■登録内容の変更はこちら\n"
    _body += "#{::Page.current_node.public_full_uri}change/\n"
    _body += "\n"
    _body += "\n"
    # signature
    _body += "#{mobile? ? content.signature_mobile : content.signature}\n" if content.signature_state == 'enabled'

    _body
  end

  def unsubscribe_notice_body
    _body = ''
    _body += "この度は、#{content.name} のご利用ありがとうございました。\n"
    _body += "\n"
    _body += "下記のURLにアクセスしていただくとメールマガジンの解除手続きが完了となります。\n"
    _body += "#{unsubscribe_uri}\n"
    _body += "\n"
    _body += "※24時間経ってもアクセスがない場合、解除受付が無効になります。お早めにアクセスしてください。\n"
    _body += "\n"
    _body += "\n"
    # signature
    _body += "#{mobile? ? content.signature_mobile : content.signature}\n" if content.signature_state == 'enabled'
    _body
  end

  def unsubscribe_complete_body
    _body = ''
    _body += "#{content.name} の解除が完了いたしました。\n"
    _body += "これまでのご利用ありがとうございました。\n"
    _body += "\n"
    # signature
    _body += "#{mobile? ? content.signature_mobile : content.signature}\n" if content.signature_state == 'enabled'
    _body
  end

end