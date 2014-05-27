require "./initialize"

Dir.glob("./lib/tasks/*").sort.each { |file| import file }

def exports
  "ENV=#{Arrival.env} RACK_ENV=#{Arrival.env}"
end

task :start do
  puts "Starting archivos in #{Arrival.env}"
  system("bundle exec thin -o 8080 start -d -l #{Arrival.log_dir}/thin.log") # start api
end

task :stop do
  system("bundle exec thin -o 8080 stop; true") # stop api
end
