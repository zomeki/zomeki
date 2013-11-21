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

    @form_answer = form_answer

    mail from: from,
         to: to,
         subject: "【#{form_answer.form.content.site.name.presence || 'ZOMEKI'}】回答が届きました。"
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
         subject: "【#{content.site.name.presence || 'ZOMEKI'}】承認依頼（#{content.name}）"
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
         subject: "【#{content.site.name.presence || 'ZOMEKI'}】承認完了（#{content.name}）"
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
         subject: "【#{content.site.name.presence || 'ZOMEKI'}】差し戻し（#{content.name}）"
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
         subject: "【#{content.site.name.presence || 'ZOMEKI'}】引き戻し（#{content.name}）"
  end
end
