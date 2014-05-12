require "arrival/models/station"

CLASSES = [Arrival::Station]
namespace :db do
  desc "Drop all data for current env"
  task :drop do
    Mongoid.default_session.drop
  end

  desc "Recreates db with indexes"
  task :recreate => [:drop, "indexes:create"]

  desc "Seed stub"
  task :seed do
    Rake::Task["geo:seed"].invoke
  end

  namespace :indexes do
    desc "Create indexes"
    task :create do
      CLASSES.each { |klass| klass.create_indexes }
    end

    desc "Drop indexes"
    task :drop do
      CLASSES.each { |klass| klass.remove_indexes }
    end
  end
end


