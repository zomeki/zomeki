namespace :zomeki do
  namespace :rank do
    namespace :ranks do
      desc 'Fetch ranking'
      task(:exec => :environment) do
        Script.run('rank/script/ranks/exec')
      end
    end
  end
end
