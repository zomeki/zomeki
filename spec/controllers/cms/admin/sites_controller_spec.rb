require 'spec_helper'

describe Cms::Admin::SitesController do
  before do
    Core.initialize({})
    Core.user = fg_find_or_create(:sys_user_site_admin)
    Core.user_group = Core.user.groups.first
    site = fg_find_or_create(:cms_site_first_example_com)
    Core.env['HTTP_COOKIE'] = "cms_site=#{site.id}"
# TODO: logged_in? にtrueを返させる処理が必要
  end

  context "when user doesn't have site_creatable" do
    describe 'GET #new' do
      describe 'routes' do
        subject { {get: "/#{ZomekiCMS::ADMIN_URL_PREFIX}/cms/sites/new"} }
        it { should route_to(controller: 'cms/admin/sites', action: 'new') }
      end

      describe 'response' do
        before do
          Core.recognize_path("/#{ZomekiCMS::ADMIN_URL_PREFIX}/cms/sites/new")
          get 'new'
        end

        subject { response }
        it { should_not be_success }
        its(:status) { pending; should eq(403) }
      end
    end
  end
end
