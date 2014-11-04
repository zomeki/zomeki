class CommonMailer < ActionMailer::Base
  default charset: 'ISO-2022-JP'

  def plain(options)
    @body_text = options[:body]
    mail from: options[:from],
         to: options[:to],
         subject: options[:subject]
  end

  def survey_receipt(form_answer: nil, from: nil, to: nil)
    raise ArgumentError.new('form_answer required.') unless form_answer.kind_of?(Survey::FormAnswer)
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.to_s.blank? || to.to_s.blank?

    content = form_answer.form.content
    @form_answer = form_answer

    mail from: from,
         to: to,
         subject: "#{@form_answer.form.title}（#{content.site.name}）：回答メール"
  end

  def survey_auto_reply(form_answer: nil, from: nil, to: nil)
    raise ArgumentError.new('form_answer required.') unless form_answer.kind_of?(Survey::FormAnswer)
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.to_s.blank? || to.to_s.blank?

    @content = form_answer.form.content
    @form_answer = form_answer

    mail from: from,
         to: to,
         subject: "#{@form_answer.form.title}（#{@content.site.name}）：受信確認自動返信メール"
  end

  def approval_request(approval_request: nil, preview_url: nil, approve_url: nil, from: nil, to: nil)
    raise ArgumentError.new('approval_request required.') if approval_request.nil?
    raise ArgumentError.new('preview_url required.') if preview_url.nil?
    raise ArgumentError.new('approve_url required.') if approve_url.nil?
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.nil? || to.nil?

    content = approval_request.approvable.content
    @approval_request = approval_request
    @preview_url = preview_url
    @approve_url = approve_url

    mail from: from,
         to: to,
         subject: "#{content.name}（#{content.site.name}）：承認依頼メール"
  end

  def approved_notification(approval_request: nil, publish_url: nil, from: nil, to: nil)
    raise ArgumentError.new('approval_request required.') if approval_request.nil?
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.nil? || to.nil?
    raise ArgumentError.new('publish_url required.') if publish_url.nil?

    content = approval_request.approvable.content
    @approval_request = approval_request
    @publish_url = publish_url

    mail from: from,
         to: to,
         subject: "#{content.name}（#{content.site.name}）：承認完了メール"
  end

  def passbacked_notification(approval_request: nil, approver: nil, detail_url: nil, comment: '', from: nil, to: nil)
    raise ArgumentError.new('approval_request required.') if approval_request.nil?
    raise ArgumentError.new('approver required.') if approver.nil?
    raise ArgumentError.new('detail_url required.') if detail_url.nil?
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.nil? || to.nil?

    content = approval_request.approvable.content
    @approval_request = approval_request
    @approver = approver
    @detail_url = detail_url
    @comment = comment

    mail from: from,
         to: to,
         subject: "#{content.name}（#{content.site.name}）：差し戻しメール"
  end

  def pullbacked_notification(approval_request: nil, detail_url: nil, comment: '', from: nil, to: nil)
    raise ArgumentError.new('approval_request required.') if approval_request.nil?
    raise ArgumentError.new('detail_url required.') if detail_url.nil?
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.nil? || to.nil?

    content = approval_request.approvable.content
    @approval_request = approval_request
    @detail_url = detail_url
    @comment = comment

    mail from: from,
         to: to,
         subject: "#{content.name}（#{content.site.name}）：引き戻しメール"
  end

  def commented_notification(comment)
    @doc = comment.doc

    d = Zomeki.config.application['sys.core_domain']
    @core_uri = (d == 'core') ? Core.full_uri : @doc.content.site.full_uri;

    from = comment.author_name
    from << " <#{comment.author_email}>" if comment.author_email.present?

    mail from: from,
         to: @doc.creator.user.email,
         subject: "#{@doc.content.name}（#{@doc.content.site.name}）：コメント通知メール"
  end
end
