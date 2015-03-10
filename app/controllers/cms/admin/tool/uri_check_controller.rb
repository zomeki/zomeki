class Cms::Admin::Tool::UriCheckController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @methods = %w!get post!
    @schemes = %w!http https!
  end

  def index
    @target = params[:target] || {}
    @query_keys = @target[:query_keys] || Array.new(5)
    @query_values = @target[:query_values] || Array.new(5)

    return unless request.post?

    begin
      fail "Invalid method: #{@target[:method]}" unless @methods.include?(@target[:method])
      method = @target[:method].to_s
      url = URI::Generic.build(scheme: @target[:scheme], host: @target[:host]).to_s
      path = @target[:path].to_s
      query = {}
      @query_keys.zip(@query_values).each{|k, v| query[k] = v if v.present? }
    rescue => e
      warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
      return
    end

    conn = Faraday.new(url: url) do |builder|
        builder.adapter Faraday.default_adapter
      end
    res = conn.send(method, path, query)
    @result = if res.success?
                content_type = res.headers['content-type'].to_s.split(';').map(&:strip)
                begin
                  if content_type[0].downcase == 'application/json'
                    JSON.parse(res.body).pretty_inspect
                  else
                    if matched = content_type[1].to_s.match(/(?<=charset=).+\z/)
                      res.body.force_encoding(matched[0])
                    else
                      raise 'charset not found in content-type'
                    end
                  end
                rescue => e
                  warn_log "#{__FILE__}:#{__LINE__} #{e.message}"
                  res.body.encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
                end
              else
                res.headers['status']
              end
  end
end
