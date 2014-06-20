class GpArticle::Script::ArchivesController < Cms::Controller::Script::Publication
  def publish
    render text: 'OK'
  end
end
