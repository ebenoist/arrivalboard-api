require "json"
require "arrival/models/train_station"
require "arrival/models/bus_stop"
require "fileutils"

namespace :geo do
  def run(cmd)
    system(cmd)
  end

  class String
    def unindent_and_join
      gsub(/^\s+/, '')
      gsub("\n","")
    end
  end

  def seed_features!(features, klass)
    puts "Seeding #{features.size} #{klass.to_s}..."
    features.each do |feature|
      properties = feature["properties"]
      geo = { "geometry" => feature["geometry"] }

      properties.merge!(geo)
      # puts "Creating: #{properties}"

      klass.create!(properties)
    end
  end

  def convert_to_geojson!(shp_file, json_file)
    run("ogr2ogr -f geoJSON #{json_file} #{shp_file}")
    geojson = JSON.parse(File.read("#{json_file}"))
  end

  def sanitize_shp!(input_file, output_file, sql)
    run("ogr2ogr -sql \"#{sql}\" #{output_file} #{input_file}")
  end

  def seed_trains!(layer_name)
    train_sql = <<-SQL.unindent_and_join
      SELECT STATION_ID as station_id,
      LONGNAME as longname,
      LINES as lines,
      ADDRESS as address,
      GTFS as gtfs FROM '#{layer_name}'
    SQL

    seed!(layer_name, train_sql, Arrival::TrainStation)
  end

  def seed!(layer_name, sql, klass)
    build_dir = Arrival.shp_dir + "/build"
    FileUtils.mkdir_p(build_dir)

    shp = Arrival.shp_dir + "/#{layer_name}.shp"
    tmp_file = build_dir + "/#{layer_name}-CLEAN.shp"
    json_file = build_dir + "/#{layer_name}.json"

    sanitize_shp!(shp, tmp_file, sql)
    geo_json = convert_to_geojson!(tmp_file, json_file)
    seed_features!(geo_json["features"], klass)
  end

  def seed_busses!(layer_name)
    bus_sql = <<-SQL.unindent_and_join
      SELECT STOPID as stop_id,
      DIR as direction,
      ROUTESSTPG as routes,
      PUBLIC_NAM as name FROM '#{layer_name}'
    SQL

    seed!(layer_name, bus_sql, Arrival::BusStop)
  end

  desc "build and seed the train stations"
  task :seed do
    seed_trains!("train-WGS84")
    seed_busses!("bus-WGS84")
    Rake::Task["geo:clean"].invoke
  end

  task :clean do
    build_dir = Arrival.shp_dir + "/build"
    system("rm -rf #{build_dir}")
  end
end
