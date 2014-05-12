module Arrival
  class << self
    def root
      File.expand_path("../../", __FILE__)
    end

    def env
      @env ||= ENV['ENV'] || ENV['RACK_ENV'] || "development"
    end

    def database_config
      Arrival.root + "/config/mongoid.yml"
    end

    def pid_dir
      tmp_dir + "/pids"
    end

    def tmp_dir
      Arrival.root + "/tmp"
    end

    def log_dir
      Arrival.root + "/log"
    end

    def shp_dir
      Arrival.root + "/shapefiles"
    end
  end
end
