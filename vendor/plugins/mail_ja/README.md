ActionMailer ISO-2022-JP plugin (mail_ja)
=========================================

Overview
--------

* (en)

	(now translating ...)

* (ja)

	mail_jaは、Ruby on Rails 3.x 系のActionMailerでISO-2022-JPなエンコードのメールを送ることができるようになるプラグインです。


Feature
-------

* (en)

	(now translating ...)

* (ja)

	 インストールしてcharsetをISO-2022-JPに設定するだけで自動的に変換します。
	 エンコードを意識する必要が無く、コード量が少なくて済みます。


Environments
------------

### Requirements ###

* ruby 1.8.7 (1.9.2 Unconfirmed)
* gem
  * actionmailer 3.x or higher
  * mail 2.2.x or higher


Getting Start
-------------

### Install ###

	$ cd RAILS_ROOT
	$ rails plugin install http://github.com/ma2shita/mail_ja.git

OR

	$ cd RAILS_ROOT
	$ git submodule add http://github.com/ma2shita/mail_ja.git vendor/plugins/mail_ja/


### Code ###

	class UserMailer < ActionMailer::Base
	  default :from => "bar@example.com", :charset => 'ISO-2022-JP'
	  def notice
	    mail(:to => 'foo@example.com', :subject => '日本語件名') do |format|
	      format.text { render :inline => '日本語本文' }
	    end
	  end
	end

	mail = UserMailer.notice
	mail.subject
	 => "=?ISO-2022-JP?B?GyRCRnxLXDhsN29MPhsoQg==?="
	NKF.nkf('-mw', mail.subject)
	 => "日本語件名"
	mail.body.encoded
	 => "\e$BF|K\\8lK\\J8\e(B"
	NKF.nkf('-w', mail.body.encoded)
	 => "日本語本文"


License
-------

(en) "mail_ja" released under the MIT license (MIT-LICENSE.txt)

(ja) "mail_ja" は MITライセンスで配布してます。 (MIT-LICENSE.txt)

[EoF]
