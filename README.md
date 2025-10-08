# Tv-Share-Backend

[API Docs](https://github.com/kwabena-offei/Tv-Share-Backend/blob/master/tvsharedb/README-API.md)

[Websockets Docs](https://github.com/kwabena-offei/Tv-Share-Backend/blob/master/tvsharedb/README-WEBSOCKETS.md)

## Local Setup

__Setup your database:__ `bundle exec rake db:setup`
This should create the database, run the migrations, and seed the database with a list of networks.

__Import shows into your database:__
- Open a Rails console:
  ```bash
  bundle exec rails console
  ```
- Start the job:
  ```ruby
  ImportLiveGuideJob.perform_now
  ```
- This will start importing shows that are currently airing on TV. Let this run for a couple of minutes and then feel free to stop it (by pressing `ctrl+c`)

You should now have a number of Networks and real shows in your database.

## GraceNote Comment Bot

This repository includes a Node.js script that posts daily comments using episode metadata from GraceNote.
Set the `GRACENOTE_API_KEY` environment variable (see `tvsharedb/env.example`) so the script can authenticate with the service.

Run the job locally with:

```bash
npm run comment-bot --prefix tvsharedb
```

On Heroku, configure the Scheduler add-on to execute the same command each day.

## Environment Variable Check

Before starting the server, you can verify that all required `.env` keys are
present. The repo includes a helper script:

```bash
npm run check-env --prefix tvsharedb
```

If any variables from `tvsharedb/env.example` are missing, the script prints the
keys and exits with an error code.

Rails also performs this check automatically on boot. The `config/initializers/env_check.rb` file loads `tvsharedb/env.example` and raises an error if any of the listed keys are absent.
