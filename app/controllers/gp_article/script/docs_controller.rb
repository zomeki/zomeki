class GpArticle::Script::DocsController < Cms::Controller::Script::Publication
  def publish
    uri = @node.public_uri.to_s
    path = @node.public_path.to_s
    smart_phone_path = @node.public_smart_phone_path.to_s
    publish_page(@node, :uri => "#{uri}index.rss", :path => "#{path}index.rss", :dependent => :rss)
    publish_page(@node, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)
    publish_more(@node, :uri => uri, :path => path, :smart_phone_path => smart_phone_path)
    render text: 'OK'
  end

  def publish_by_task
    if (item = params[:item]).try(:state_approved?)
      Script.current
      info_log "-- Publish: #{item.class}##{item.id}"

      uri = item.public_uri.to_s
      path = item.public_path.to_s

      # Renew edition before render_public_as_string
      item.update_attribute(:state, 'public')

      if item.publish(render_public_as_string(uri, :site => item.content.site))
        Sys::OperationLog.script_log(:item => item, :site => item.content.site, :action => 'publish')
      else
        raise item.errors.full_messages
      end

      if item.published? || !::File.exist?("#{path}.r")
        uri_ruby = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
        path_ruby = "#{path}.r"
        item.publish_page(render_public_as_string(uri_ruby, :site => item.content.site),
                          :path => path_ruby, :dependent => :ruby)

        share_to_sns(item)
        publish_related_pages(item)
      end

      info_log %Q!OK: Published to "#{path}"!
      params[:task].destroy
      Script.success
    end
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: 'NG'
  end

  def close_by_task
    if (item = params[:item]).try(:state_public?)
      Script.current
      info_log "-- Close: #{item.class}##{item.id}"

      item.close
      publish_related_pages(item)

      Sys::OperationLog.script_log(:item => item, :site => item.content.site, :action => 'close')

      info_log 'OK: Closed'
      params[:task].destroy
      Script.success
    end
    render text: 'OK'
  rescue => e
    error_log e.message
    render text: 'NG'
  end

  private

  def share_to_sns(item)
    view_helpers = self.class.helpers

    item.sns_accounts.each do |account|
      next if account.credential_token.blank?

      begin
        apps = YAML.load_file(Rails.root.join('config/sns_apps.yml'))[account.provider]

        case account.provider
        when 'facebook'
          fb = RC::Facebook.new(access_token: account.credential_token.presence)
          message = view_helpers.strip_tags(item.send(item.share_to_sns_with))
          info_log fb.post("#{account.facebook_page}/feed", message: message)
        when 'twitter'
          if (app = apps[request.host])
            tw = RC::Twitter.new(consumer_key: app['key'],
                                 consumer_secret: app['secret'],
                                 oauth_token: account.credential_token.presence,
                                 oauth_token_secret: account.credential_secret.presence)
            message = view_helpers.truncate(view_helpers.strip_tags(item.send(item.share_to_sns_with)), length: 140)
            info_log tw.tweet(message)
          end
        end
      rescue => e
        warn_log %Q!Failed to "#{account.provider}" share: #{e.message}!
      end
    end
  end

  def publish_related_pages(item)
    Delayed::Job.where(queue: ['publish_top_page', 'publish_category_pages']).destroy_all

    if (root_node = item.content.site.nodes.public.where(parent_id: 0).first) &&
       (top_page = root_node.children.where(name: 'index.html').first)
      ::Script.delay(queue: 'publish_top_page')
              .run("cms/script/nodes/publish?target_module=cms&target_node_id=#{top_page.id}", force: true)
    end

    GpCategory::Publisher.register_categories(item.category_ids)
    GpCategory::Publisher.delay(queue: 'publish_category_pages').publish_categories
  end
end
