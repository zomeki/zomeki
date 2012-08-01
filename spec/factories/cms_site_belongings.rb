# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cms_site_belonging, :class => 'Cms::SiteBelonging' do
# TODO: siteとgroupのfactoryを作成後更新する
    site nil
    group nil
  end
end
