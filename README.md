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
   ```
   export GOOGLEMAPSAPIKEY=<your google maps API key>
   export ZOOPLAAPIKEY=<your Zoopla API key>
   export POSTGRES_PASSWORD=<make up a password for the DB user 'admin'>
   export SECRET_KEY=`openssl rand -hex 32`
   export CLIENT_ID=<OAuth2.0 client ID, in GCP API & Services -> Credentials>

   ```
   - `SECRET_KEY` is used for auth and should be a random 32 digit hex value. The `openssl` command above is a simple way to generate this, but you can use whatever key you like.
   - If you want to connect to an existing database, instead of `POSTGRES_PASSWORD`, set an environment variable called `DATABASE_URL` with the full connection string. This is the environment variable name used by Heroku.
1. Build and run:
   ```
   docker compose up
   ```
1. Test the backend:
   ```
   curl localhost:80/pdf/acf057f7f02b0cf3552e149de5772640bf0bfd2c.pdf
   ```
   This can take around 10s but should return `{"area":442.6}`
1. The front end should be available at:
   ```
   localhost:5001
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
1. [Install the heroku cli and log in](https://devcenter.heroku.com/articles/heroku-cli)
1. Set the name for your heroku app:
   ```bash
   export APP_NAME=<your app name>
   ```
1. Create the app:
   ```bash
   heroku create $APP_NAME
   ```
1. Set the following config variables in Heroku 
   - `GOOGLEMAPSAPIKEY`: your Google Maps API key
   - `ZOOPLAAPIKEY`: your Zoopla API key
   - `SECRET_KEY`: A random key generated using`openssl rand -hex 32` or something similar.
   - `CLIENT_ID`: Your OAuth2.0 client ID. In GCP API & Services -> Credentials.
1. Add the postgres add-on to your Heroku app.
1. Log in to the Heroku container registery:
   ```bash
    heroku container:login
   ```
1. Build the images locally, most easily done via: 
   ```bash
   docker compose up -d
   ```
   You can stop the containers using `docker down`.
1. Tag the images:
   ```bash
   docker tag home-search_backend registry.heroku.com/$APP_NAME/api
   docker tag home-search_frontend registry.heroku.com/$APP_NAME/web
   ```
1. Push to Heroku (wait for first to complete):
   ```bash
   docker push registry.heroku.com/$APP_NAME/api
   docker push registry.heroku.com/$APP_NAME/web
   ```
1. Release the image
   ```bash
   heroku container:release --app $APP_NAME api
   heroku container:release --app $APP_NAME web
   ```
1. open the app
   ```
   heroku open --app $APP_NAME
   ```
