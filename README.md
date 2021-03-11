# Home Search

An app to search for properties on Zoopla and filter on the properties total area. The area is scraped off the floorplan image using OCR.


## Local Deployment

This project consists of a frontend (web) application written in Flutter, and a backend service written in Python. The backend requires access to a postgres database. 

The simplest way to deploy it locally is to use docker:

1. From the project root directory:
1. [Create a Google Maps API key](https://developers.google.com/maps/documentation/javascript/get-api-key) if you don't have one.
1. [Create a Google Sign-in Client ID](https://developers.google.com/identity/sign-in/web/sign-in) if you don't have one.
1. [Create a Zoopla API key](https://developer.zoopla.co.uk/) if you don't have one.
1. Set environment variables for API keys:
   ```bash
   export GOOGLEMAPSAPIKEY=<your google maps API key>
   export ZOOPLAAPIKEY=<your Zoopla API key>
   export POSTGRES_PASSWORD=<make up a password for the DB user 'admin'>
   export SECRET_KEY=`openssl rand -hex 32`
   export CLIENT_ID=<OAuth2.0 client ID, in GCP API & Services -> Credentials>
   export URL_API=localhost  # or http:/127.0.0.1
   ```
   - `SECRET_KEY` is used for auth and should be a random 32 digit hex value. The `openssl` command above is a simple way to generate this, but you can use whatever key you like.
   - If you want to connect to an existing database, instead of `POSTGRES_PASSWORD`, set an environment variable called `DATABASE_URL` with the full connection string. This is the environment variable name used by Heroku.
1. Build and run:
   ```bash
   docker compose up
   ```
1. Test the backend:
   ```bash
   curl localhost:80/pdf/acf057f7f02b0cf3552e149de5772640bf0bfd2c.pdf
   ```
   This can take around 10s but should return `{"area":442.6}`
1. The front end should be available at:
   ```
   localhost:5001
   ```
1. The OpenAPI docs foe the backend are available at:
   ```
   localhost/docs
   ```

If you need to force a rebuild of the containers, try:
 
```bash
docker-compose build --no-cache
```

If you need to clear the DB:
```bash
docker volume prune
```


## Server Deployment (Heroku)
The following instructions show you how to create a new deployment for this app on Heroku. If you have already done this, you can run the `deploy.sh` script instead, which only assumes you have set the `APP_NAME` environment variable.

1. [Install the heroku cli and log in](https://devcenter.heroku.com/articles/heroku-cli)
1. Set the name for your heroku app:
   ```bash
   export APP_NAME=<your app name>
   export API_NAME=${APP_NAME}server
   ```
1. Create two apps, one for the frontend, and one for the backend:
   ```bash
   heroku create $APP_NAME
   heroku create $API_NAME
   ```
1. Set the following config variables in Heroku:
   - `GOOGLEMAPSAPIKEY`: your Google Maps API key
   - `ZOOPLAAPIKEY`: your Zoopla API key
   - `SECRET_KEY`: (Only for backend) A random key generated using`openssl rand -hex 32` or something similar.
   - `CLIENT_ID`: Your OAuth2.0 client ID. In GCP API & Services -> Credentials.
1. Set the following environment variables:
   ```bash
   export URL_API=https://${API_NAME}.herokuapp.com
   ```
   note `URL_API` is a build arg for the FrontEndDockerfile, but you don't have to worry about this if you use `docker compose`.
1. Add the postgres add-on to your backend Heroku app, i.e. the one name `$API_NAME` which should end in `server`. Note you should first check that you haven't already provisioned postgres by running `heroku addons --app $API_NAME`.
   ```bash
   heroku addons:create heroku-postgresql:hobby-dev --app $API_NAME
   ```
1. Log in to the Heroku container registry:
   ```bash
   heroku container:login
   ```
1. Build the images locally, most easily done via: 
   ```bash
   docker compose up -d
   ```
   You can stop the containers using `docker compose down` as you don't need them.
1. Tag the images:
   ```bash
   docker tag home-search_backend registry.heroku.com/$API_NAME/web
   docker tag home-search_frontend registry.heroku.com/$APP_NAME/web
   ```
1. Push to Heroku (wait for first to complete):
   ```bash
   docker push registry.heroku.com/$API_NAME/web
   docker push registry.heroku.com/$APP_NAME/web
   ```
1. Release the containers
   ```bash
   heroku container:release --app $API_NAME web
   heroku container:release --app $APP_NAME web
   ```
1. Scale up your dynos:
   ```bash
   heroku ps:scale --app $API_NAME web=1
   heroku ps:scale --app $APP_NAME web=1
   ```
1. open the app
   ```
   heroku open --app $APP_NAME
   ```
