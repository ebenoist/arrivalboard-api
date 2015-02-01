FROM ruby:2.2-onbuild
RUN apt-get update && apt-get install -y gdal-bin
RUN bundle exec rspec
CMD ["bundle", "exec", "thin", "start"]
EXPOSE 3000
