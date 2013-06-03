# encoding: utf-8

namespace :zomeki do
  namespace :gp_article do
    task :set_user_and_group do
      Core.user       = Sys::User.first
      Core.user_group = Core.user.group
    end

    namespace :load do
      desc 'Load documents.'
      task(:documents =>  [:environment, :set_user_and_group]) do
        next if (content_id = ENV['content_id'].to_i).zero?

        documents = YAML.load_file(Rails.root.join("tmp/gp_article_#{content_id}_documents.yml"))
        documents.each do |document|
          doc = GpArticle::Doc.create!(content_id: content_id,
                                       title: document[:title],
                                       body: document[:body],
                                       published_at: document[:published_at])

          if (gp_category = GpArticle::Content::Doc.find_by_id(content_id).try(:gp_category))
            category_type = gp_category.category_types.find_by_name('categories')
            doc.category_ids = document[:category_names].split(',').map {|cn| category_type.categories.find_by_name(cn).try(:id) }
          end

          if doc.body.index('="./files/') && (source_doc = Article::Doc.find_by_title_and_body(doc.title, doc.body))
            doc.update_attribute(:body, doc.body.gsub('="./files/', '="file_contents/'))

            Sys::File.where(parent_unid: source_doc.unid).each do |source_file|
              target_file = Sys::File.new(parent_unid: doc.unid,
                                          name: source_file.name,
                                          title: source_file.title,
                                          mime_type: source_file.mime_type,
                                          size: source_file.size,
                                          image_is: source_file.image_is,
                                          image_width: source_file.image_width,
                                          image_height: source_file.image_height)
              target_file.skip_upload
              target_file.save!

              FileUtils.mkdir_p(File.dirname(target_file.upload_path))
              FileUtils.copy(source_file.upload_path, target_file.upload_path, preserve: true)
            end
          end
        end
      end
    end
  end
end
