# encoding: utf-8
class Enquete::Script::AnswersController < ApplicationController

  def pull
    options = ::Script.options || {:database => :slave}
    options = {:database => options} if !options.is_a?(Hash)
    if !options[:database].is_a?(Array)
      options[:database] = [ options[:database] ]
    end
    
    success = 0
    error   = 0
    
    options[:database].each do |spec|
      begin
        slave  = SlaveBase.establish_connection(spec)
      rescue => e
        puts "Error: #{e}"
        next
      end
      
      select = "SELECT id FROM enquete_answers WHERE created_at < '#{(Time.now - 5).strftime('%Y-%m-%d %H:%M:%S')}'"
      slave.connection.execute(select).each_hash do |v|
        begin
          id = v['id']
          raise "Unknown Answer ID ##{id}" if id.blank?
          
          ## fetch
          in_ans = slave.connection.execute("SELECT * FROM enquete_answers WHERE id = #{id}")
          raise "Answer Not Found ##{id}" unless in_ans
          in_cols = slave.connection.execute("SELECT * FROM enquete_answer_columns WHERE answer_id = #{id}")
          raise "Answer Columns Not Found ##{id}" unless in_cols
          
          ## copy
          ans = Enquete::Answer.new(in_ans.fetch_hash)
          raise "Could Not Save Answer ##{id}" unless ans.save
          col_error = nil
          in_cols.each_hash do |in_col|
            col = Enquete::AnswerColumn.new(in_col)
            col.answer_id = ans.id
            col_error = true unless col.save
          end
          raise "Could Not Save Column ##{id}" if col_error
          
          ## delete
          slave.connection.execute("DELETE FROM enquete_answers WHERE id = #{id}")
          slave.connection.execute("DELETE FROM enquete_answer_columns WHERE answer_id = #{id}")
          
          success += 1
        rescue => e
          error += 1
          puts "Error: #{e}"
        end
      end
    end
    
    puts "Pulled: Success=#{success}, Error=#{error}"
    render :text => 'OK'
    
  rescue => e
    puts e
    render :text => 'NG'
  end
end
