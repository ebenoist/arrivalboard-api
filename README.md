Arrival::API
---
Backend API that allows for GEO queries against list of CTA stations

## Requirements
- [mongodb](http://www.mongodb.org/)
- [ruby 2.2](https://www.ruby-lang.org/en/)
- [gdal](http://www.gdal.org/)

## Usage
```BASH
bundle exec rake db:recreate
bundle exec rackup
```

## Deploy
```BASH
git push origin head:release
TAG=docker-tag ENV=production script/deploy
```

```curl "localhost:9292/v1/stations?lat=41.9234183&lng=-87.7021779&buffer=1000"```

```JSON
[
    {
        "route": "Blue",
        "station": "California",
        "destination": "O'Hare",
        "arrival_time": "2014-05-17T15:33:58-05:00"
    },
    {
        "route": "Blue",
        "station": "California",
        "destination": "O'Hare",
        "arrival_time": "2014-05-17T15:41:49-05:00"
    },
    {
        "route": "Blue",
        "station": "California",
        "destination": "Forest Park",
        "arrival_time": "2014-05-17T15:41:58-05:00"
    },
    {
        "route": "Blue",
        "station": "Logan Square",
        "destination": "O'Hare",
        "arrival_time": "2014-05-17T15:35:58-05:00"
    },
    {
        "route": "Blue",
        "station": "Logan Square",
        "destination": "Forest Park",
        "arrival_time": "2014-05-17T15:37:58-05:00"
    },
    {
        "route": "Blue",
        "station": "Logan Square",
        "destination": "O'Hare",
        "arrival_time": "2014-05-17T15:44:49-05:00"
    }
]
```

## Contributing

1. Fork it ( https://github.com/ebenoist/arrival-api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
