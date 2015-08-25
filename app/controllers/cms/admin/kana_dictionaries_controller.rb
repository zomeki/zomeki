# encoding: utf-8
class Cms::Admin::KanaDictionariesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end
  
  def index
    return test if params[:do] == 'test'
    return make_dictionary if params[:do] == 'make_dictionary'

    @items = Cms::KanaDictionary.where(site_id: Core.site.id).order(:id)
                                .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end
  
  def show
    @item = Cms::KanaDictionary.new.find(params[:id])
    return error_auth unless @item.readable?
    return error_auth unless @item.site_id == Core.site.id
    
    _show @item
  end

  def new
    @item = Cms::KanaDictionary.new({
      :body => "" +
        "# コメント ... 先頭に「#」\n" +
        "# 辞書には登録されません。\n\n" +
        "# 日本語例 ... 「漢字, カタカナ」\n" +
        "文字, モジ\n" +
        "単語, タンゴ\n\n" +
        "# 英字例 ... 「英字, カタカナ」\n" +
        "ZOMEKI, ゾメキ\n"
    })
  end
  
  def create
    return test if params[:do] == 'test'
    
    @item = Cms::KanaDictionary.new(params[:item])
    @item.site_id = Core.site.id
    _create @item
  end
  
  def update
    @item = Cms::KanaDictionary.new.find(params[:id])
    return error_auth unless @item.site_id == Core.site.id

    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Cms::KanaDictionary.new.find(params[:id])
    return error_auth unless @item.site_id == Core.site.id

    _destroy @item
  end
  
  def make
    res = Cms::KanaDictionary.make_dic_file(Core.site.id)
    if res == true
      flash[:notice] = '辞書を更新しました。'
    else
      flash[:notice] = res.join('<br />')
    end
    
    redirect_to cms_kana_dictionaries_url
  end
  
  def test
    @mode = true
    
    if params[:yomi_kana]
      render :inline => Cms::Lib::Navi::Kana.convert(params[:body], Core.site.id)
    elsif params[:talk_kana]
      render :inline => Cms::Lib::Navi::Jtalk.make_text(params[:body], Core.site.id)
    elsif params[:talk_file]
      jtalk = Cms::Lib::Navi::Jtalk.new
      jtalk.make params[:body], {:site_id => Core.site.id}
      file = jtalk.output
      send_file(file[:path], :type => file[:path], :filename => 'sound.mp3', :disposition => 'inline')
    end
  end
end
