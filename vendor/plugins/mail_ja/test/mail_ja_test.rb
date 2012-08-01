#coding:utf-8
require 'test_helper'

require 'action_mailer'
require File.dirname(__FILE__) + '/../init'

class MailJaTest < ActiveSupport::TestCase
  test "ISO-2022-JP" do
    mail = Iso2022jpMailer.notice
    assert_equal NKF::JIS, NKF.guess(mail.subject)
    assert_equal '=?ISO-2022-JP?B?GyRCRnxLXDhsN29MPhsoQg==?=', mail.subject
    assert_equal NKF::JIS, NKF.guess(mail.body.encoded)
  end

  test "ORIGIN" do
    mail = OriginMailer.notice
    assert_equal NKF::UTF8, NKF.guess(mail.subject)
    assert_equal "\346\227\245\346\234\254\350\252\236\344\273\266\345\220\215", mail.subject
    assert_equal NKF::UTF8, NKF.guess(mail.body.encoded)
  end
end

class Iso2022jpMailer < ActionMailer::Base
  default :from => "bar@example.com", :charset => 'ISO-2022-JP'
  def notice
    mail(:to => 'foo@example.com', :subject => '日本語件名') do |format|
      format.text { render :inline => '日本語本文' }
    end
  end
end

class OriginMailer < ActionMailer::Base
  default :from => "bar@example.com"
  def notice
    mail(:to => 'foo@example.com', :subject => '日本語件名') do |format|
      format.text { render :inline => '日本語本文' }
    end
  end
end
