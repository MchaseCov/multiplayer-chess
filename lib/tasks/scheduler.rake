desc 'This task is called by the Heroku scheduler add-on'
task remove_old_games: :environment do
  puts 'Updating inactive games'
  Game.remove_inactive_games
  puts 'done.'
end
