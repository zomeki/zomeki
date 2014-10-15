namespace :zomeki do
  namespace :survey do
    namespace :answers do
      desc 'Fetch survey answers'
      task(:pull => :environment) do
        Script.run('survey/script/answers/pull')
      end
    end
  end
end
