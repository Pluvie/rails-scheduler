namespace :scheduler do

  desc 'Scheduler Start'
  task :start => :environment do |t, args|
     Scheduler.start
  end
  
  desc 'Scheduler Stop'
  task :stop => :environment do |t, args|
     Scheduler.stop
  end

  desc 'Scheduler Restart'
  task :restart => :environment do |t, args|
     Scheduler.restart
  end

end