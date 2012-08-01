# encoding: utf-8
require 'nkf'
class DefaultMailer < ActionMailer::Base
  default :charset => "iso-2022-jp"
  
  def mail(fr_addr, to_addr, subject, body)
    from       fr_addr
    recipients to_addr
    subject    subject
    body       body
  end
  
  class Mail
    def self.deliver(fr_addr, to_addr, subject, body)
      mail = DefaultMailer.mail(fr_addr, to_addr, subject, body)
      if mail.charset =~ /iso-2022-jp/i
        mail.body    = NKF.nkf("-Wj", body).force_encoding('us-ascii')
      end
      mail.deliver
    end
  end
end
