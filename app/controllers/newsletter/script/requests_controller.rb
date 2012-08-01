# encoding: utf-8
class Newsletter::Script::RequestsController < ApplicationController

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

      select = "SELECT id FROM newsletter_requests WHERE request_state = 'done' order by created_at"
      slave.connection.execute(select).each_hash do |v|
        begin
          id = v['id']
          raise "Unknown Request ID ##{id}" if id.blank?

          ## fetch
          in_req = slave.connection.execute("SELECT * FROM newsletter_requests WHERE id = #{id}")
          raise "Request Not Found ##{id}" unless in_req

          ## copy
          req = Newsletter::Request.new(in_req.fetch_hash)
          #raise "Could Not Save Request ##{id}" unless req.save

          ## validate and save
          mem = Newsletter::Member.find(:first, :conditions => {:state => 'enabled', :content_id => req.content_id, :email => req.email })
          if req.subscribe?
            raise "This Email has already existed ##{id}" if mem
            raise "Could Not Save Member ##{id}" unless Newsletter::Member.new({
              :state        => 'enabled',
              :content_id   => req.content_id,
              :letter_type  => req.letter_type,
              :email        => req.subscribe_email,
            }).save

          else
            raise "This Email doesn't exist ##{id}" unless mem
            mem.state = 'disabled'
            raise "Could Not Save Member ##{id}" unless mem.save
          end

          ## delete
          slave.connection.execute("DELETE FROM newsletter_requests WHERE id = #{id}")

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


  def delete
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

     # before 24 hours
     delete = "DELETE FROM newsletter_requests WHERE created_at < '#{(Time.now - 86400).strftime('%Y-%m-%d %H:%M:%S')}'"
      begin
        res = slave.connection.execute(delete)
      rescue => e
        puts "Error: #{e}"
      end
    end

    puts "Deleted: Success"
    render :text => 'OK'

  rescue => e
    puts e
    render :text => 'NG'
  end

end
