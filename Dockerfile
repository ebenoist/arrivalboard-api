FROM ruby:2.2-onbuild
RUN apt-get update && apt-get install -y gdal-bin
RUN bundle exec rspec
CMD ["bundle", "exec", "unicorn"]
EXPOSE 8080
