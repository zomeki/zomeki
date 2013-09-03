# encoding: utf-8
namespace :zomeki do
  namespace :cms do
    namespace :link_check do
      desc 'Check links.'
      task(:check => :environment) do
        Util::LinkChecker.check
      end
    end
  end
end
