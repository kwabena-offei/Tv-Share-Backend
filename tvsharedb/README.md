# TV Chat Backend

### Environment variables
Sensitive strings like api_keys should not be checked into git.

Locally these keys should be saved in a `.env` file. That's a file without a name but with an `env` extention. We're using a gem called [dotenv](https://github.com/bkeepers/dotenv) to handle this.


Sample .env file:
```
TMS_API_KEY=abc123
API_HOST=https://tvchat-api.herokuapp.com
NEWS_API_HOST=https://tvchat-news-search.herokuapp.com
```

Whenever your application loads, these variables will be available in `ENV`:

```ruby
ENV['TMS_API_KEY']
ENV['API_HOST']
ENV['NEWS_API_HOST']
```

In production, we should use [config variables](https://devcenter.heroku.com/articles/config-vars). `heroku config:set TMS_API_KEY=123`.

#### Environment variable summary

- `REDIS_URL` - Redis connection used by Sidekiq and websockets.
- `BING_API_KEY` - API key for Bing search.
- `CLOUDINARY_URL` - Credentials for Cloudinary image uploads.
- `GOOGLE_AUTH_CLIENT_ID` - OAuth client ID for Google login.
- `TMS_API_KEY` - API key for GraceNote/TMS metadata.
- `GRACENOTE_API_KEY` - Alternative GraceNote API key.
- `FRONT_END_URL` - Base URL of the front-end application.
- `API_HOST` - Host for the public API.
- `NEWS_API_HOST` - Host for the news search service.
- `MAILGUN_SMTP_PORT` - Port for Mailgun SMTP.
- `MAILGUN_SMTP_SERVER` - Mailgun SMTP server address.
- `MAILGUN_SMTP_LOGIN` - Mailgun SMTP username.
- `MAILGUN_SMTP_PASSWORD` - Mailgun SMTP password.
- `ALGOLIA_API_KEY` - Algolia search API key.
- `OPEN_AI_API_KEY` - Token for OpenAI requests.
- `OPEN_AI_ORGANIZATION_ID` - OpenAI organization identifier.
- `BOT_USER_ID` - ID of the bot user used by scripts.
- `MONGODB_URI` - MongoDB connection for the comment bot.

### Deployment
Make sure you're in the root director of the git repo (`Tv-Share-Backend`).
Then, run this command: `git subtree push --prefix tvsharedb heroku master`

If you need to force-push to heroku use this command: `git push heroku `git subtree split --prefix tvsharedb master`:master --force`. Note: Make sure you know what you're doing as this is a potentially destructive command.
