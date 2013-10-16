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
end
