class CommonMailer < ActionMailer::Base
  default charset: 'ISO-2022-JP'

  def plain(options)
    @body_text = options[:body]
    mail from: options[:from],
         to: options[:to],
         subject: options[:subject]
  end
end
