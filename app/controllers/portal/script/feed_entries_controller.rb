# encoding: utf-8
class Portal::Script::FeedEntriesController < Cms::Controller::Script::Publication
  def publish
    if @node
      uri  = "#{@node.public_uri}"
      path = "#{@node.public_path}"
      publish_more(@node, :uri => uri, :path => path, :first => 2)
    end
    render :text => "OK"
  end
end
