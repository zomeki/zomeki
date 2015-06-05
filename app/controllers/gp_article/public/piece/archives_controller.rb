class GpArticle::Public::Piece::ArchivesController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpArticle::Piece::Archive.find_by_id(Page.current_piece.id)
    return render(text: '') unless @piece

    @node = @piece.content.public_archives_node
    return render(text: '') unless @node
  end

  def index
    order = (@piece.order == 'desc' ? 'DESC' : 'ASC')
    @num_docs = @piece.content.public_docs
                              .group("DATE_FORMAT(display_published_at, '%Y-%m')")
                              .order("display_published_at #{order}").count
    @num_docs = case @piece.term
                when 'year_month'
                  @num_docs.inject({}){|result, item|
                    y, m = item[0].split('-')
                    result[y] ||= {}
                    result[y][m] ||= 0
                    result[y][m] += item[1]
                    result
                  }
                when 'year'
                  @num_docs.inject({}){|result, item|
                    y, m = item[0].split('-')
                    result[y] ||= 0
                    result[y] += item[1]
                    result
                  }
                else
                  @num_docs
                end
  end
end
