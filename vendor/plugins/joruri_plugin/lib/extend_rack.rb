# encoding: utf-8
module Rack::Mount
  class RouteSet
    def call(env)
      raise 'route set not finalized' unless @recognition_graph

      env[PATH_INFO] = Utils.normalize_path(env[PATH_INFO])

      ## ZOMEKI: rewrite path
      Core.initialize(env)
      Core.recognize_path(env[PATH_INFO])
      env[PATH_INFO] = Core.internal_uri
      
      request = nil
      req = @request_class.new(env)
      recognize(req) do |route, matches, params|
        # TODO: We only want to unescape params from uri related methods
        params.each { |k, v| params[k] = Utils.unescape_uri(v) if v.is_a?(String) }

        if route.prefix?
          env[Prefix::KEY] = matches[:path_info].to_s
        end

        old_params = env[@parameters_key]
        env[@parameters_key] = (old_params || {}).merge(params)

        result = route.app.call(env)

        if result[1][X_CASCADE] == PASS
          env[@parameters_key] = old_params
        else
          return result
        end
      end

      request || [404, {'Content-Type' => 'text/html', 'X-Cascade' => 'pass'}, ['Not Found']]
    end
  end
end
