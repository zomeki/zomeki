# encoding: utf-8
class Survey::Script::AnswersController < ApplicationController

  def pull
    
#    @sender = Joruri.config[:enquete_notice_mail_sender]

    Util::Config.load(:database, nil, :section => false).each do |section, spec|
      next if section.to_s !~ /^#{Rails.env.to_s}_pull_database/ ## only pull_database

      begin
        @db = SlaveBase.establish_connection(spec).connection

        sql = "SELECT id FROM survey_form_answers WHERE created_at < '#{(Time.now - 5).strftime('%Y-%m-%d %H:%M:%S')}'"
        ans = @db.execute(sql)

        Script.total ans.size

        ans.each(:as => :hash) do |v|
          Script.current
          pull_answer v["id"]
          Script.success
        end

      rescue Script::InterruptException => e
        raise e
      rescue => e
        Script.error e.to_s
      end
    end
    return render(:text => "OK")
  end

protected
  def pull_answer(id)
    sql = "SELECT * FROM survey_form_answers WHERE id = #{id}"
    ans_id = nil
    @db.execute(sql).each(:as => :hash) do |ans_row|
      ans = Survey::FormAnswer.new(ans_row)
      ans.save
      ans_id = ans.id

      sql = "SELECT * FROM survey_answers WHERE form_answer_id = #{id}"
      @db.execute(sql).each(:as => :hash) do |col_row|
        col = Survey::Answer.new(col_row)
        col.form_answer_id = ans.id
        col.save
      end
    end

    @db.execute("DELETE FROM survey_answers WHERE form_answer_id = #{id}")
    @db.execute("DELETE FROM survey_form_answers WHERE id = #{id}")

    begin
      @form_answer = Survey::FormAnswer.find_by_id(ans_id)
      @content     = Cms::Content.find_by_id(@form_answer.form.content_id)
#      send_answer_mail #if @sender == 'script'
    rescue => e
      error_log("メール送信失敗 #{e}")
    end
  end

  def send_answer_mail
    CommonMailer.survey_receipt(form_answer: @form_answer, from: @content.mail_from, to: @content.mail_to)
                .deliver if @content.mail_from.present? && @content.mail_to.present?
  end

end
