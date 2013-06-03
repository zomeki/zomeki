require 'spec_helper'

describe AdBanner::Admin::BannersController do
  subject { AdBanner::Admin::BannersController }
  it { should < Cms::Controller::Admin::Base }
  it { should include Sys::Controller::Scaffold::Base }

  describe 'GET #index' do
    describe 'routes' do
      subject { {get: "/#{ZomekiCMS::ADMIN_URL_PREFIX}/ad_banner/1/banners"} }
      it { should route_to(controller: 'ad_banner/admin/banners', action: 'index', content: '1') }
    end

    describe 'response' do
      before do
        Core.initialize
        login_as(fg_find_or_create(:sys_user_site_admin).account)
        fg_find_or_create(:cms_site_first_example_com)
        Core.recognize_path("/#{ZomekiCMS::ADMIN_URL_PREFIX}/ad_banner/1/banners")
      end

      it 'has banner content' do
        content = fg_find_or_create(:ad_banner_content_banner_1)
        get :index, content: content.id
        assigns(:content).should be_kind_of(AdBanner::Content::Banner)
      end
    end
  end
end
