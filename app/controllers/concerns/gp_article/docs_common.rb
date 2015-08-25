module GpArticle::DocsCommon
  extend ActiveSupport::Concern

  included do
  end

  def share_to_sns(item)
    view_helpers = self.class.helpers

    item.sns_accounts.each do |account|
      next if account.credential_token.blank?

      begin
        apps = YAML.load_file(Rails.root.join('config/sns_apps.yml'))[account.provider]

        case account.provider
        when 'facebook'
          fb = RC::Facebook.new(access_token: account.facebook_token)
          options = if item.share_to_sns_with == 'body'
                      html = Nokogiri::HTML::DocumentFragment.parse(item.body)
                      if (img_tags = html.css('img[src^="file_contents/"]')).present?
                        {picture: "#{item.public_full_uri}#{img_tags.first.attr('src')}",
                         name: item.title, message: view_helpers.strip_tags(html.to_s), link: item.public_full_uri}
                      else
                        {name: item.title, message: view_helpers.strip_tags(html.to_s), link: item.public_full_uri}
                      end
                    else
                      {link: item.public_full_uri}
                    end
          info_log fb.post("#{account.facebook_page}/feed", options)
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
    Delayed::Job.where(queue: 'publish_top_page').destroy_all
    if (root_node = item.content.site.nodes.public.where(parent_id: 0).first) &&
       (top_page = root_node.children.where(name: 'index.html').first)
      ::Script.delay(queue: 'publish_top_page')
              .run("cms/script/nodes/publish?target_module=cms&target_node_id=#{top_page.id}", force: true)
    end

    Delayed::Job.where(queue: 'publish_category_pages').destroy_all
    category_ids = if (@old_category_ids.kind_of?(Array) && @new_category_ids.kind_of?(Array))
                     @old_category_ids | @new_category_ids
                   else
                     item.categories.inject([]){|result, item|
                       result | item.ancestors.map(&:id)
                     }
                   end
    GpCategory::Publisher.register_categories(category_ids)
    GpCategory::Publisher.delay(queue: 'publish_category_pages').publish_categories
  end
end
