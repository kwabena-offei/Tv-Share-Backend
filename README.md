# Tv-Share-Backend

[API Docs](https://github.com/kwabena-offei/Tv-Share-Backend/blob/master/tvsharedb/README-API.md)

[Websockets Docs](https://github.com/kwabena-offei/Tv-Share-Backend/blob/master/tvsharedb/README-WEBSOCKETS.md)

## Local Setup

__Setup your database:__ `bundle exec rake db:setup`
This should create the database, run the migrations, and seed the database with a list of networks.

__Import shows into your database:__
- Open a rails console: `bundle exec rails console`
- Start the `ImportLiveGuideJob.perform_now`
- This will start importing shows that are currently airing on TV. Let this run for a couple of minutes and then feel free to stop it (by pressing `ctrl+c`)

You should now have a number of Networks and real shows in your database.