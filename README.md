# Home Search

An app to search for properties on Zoopla and filter on the properties total area. The area is scraped off the floorplan image using OCR.


## Local Deployment

This project consists of a frontend (web) application written in Flutter, and a backend service written in Python. The backend requires access to a postgres database. The simplest way to deploy it locally is to use docker:

1. From the project root directory:
1. [Create a Google Maps API key](https://developers.google.com/maps/documentation/javascript/get-api-key) if you don't have one.
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
   -
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

   ```
   docker-compose build --no-cache
   ```

https://lc.zoocdn.com/beab1b66c04a52e4f8d74c5688e047cd8c5eb332.jpg
----
# Old readme - needs to be cleaned up


## OCR service

You can either deploy is via docker or manually

### Deploy with Docker

Create an environment variable with a version number
```
export TAG=0.1
```

Create an environment variable with your google maps API key
```bash
export MAPSAPIKEY=<your key>
```

Build the image:
```bash
docker build . -f OCRDockerfile -t home_search_ocr:$TAG
```

Run the container:
```bash
docker run -d --env MAPSAPIKEY --name ocr -p 80:80 home_search_ocr:$TAG
docker run -d --name web -p 5001:5001 home_search_web:$TAG
```

Test it
### Calling the service

```bash
curl localhost/image/f9bcacc95fcbeb8e7490ad7cc6726f667785b6e2.jpg
curl localhost/pdf/acf057f7f02b0cf3552e149de5772640bf0bfd2c.pdf
```


### Deploy manually

If you haven't already:

1. `python3 -m venv .env`
1. `source .env/bin/activate`
1. `pip install -r requirements.txt`
1. `brew install poppler`

### Running the service

1. `cd ocr_service`
1. `uvicorn main:app --reload`

### Calling the service

1. send a request to where ever the service is running (e.g. `http://127.0.0.1:8000`) followed by `/{file_type}/{image_file}`.
   e.g. `curl http://127.0.0.1:8000/image/f9bcacc95fcbeb8e7490ad7cc6726f667785b6e2.jpg` or
   `curl http://127.0.0.1:8000/pdf/acf057f7f02b0cf3552e149de5772640bf0bfd2c.pdf`

### Examples:
- More than one area:
  - `curl localhost/jpg/d9dfc791e696ced419c31d54b4c3a66535098457`
  - should return maximum area of `115.7`
- .png:
  - `curl localhost/image/a64beb115ca989474d2589b96043fcf663ba3207.png`
- no area
  - https://lc.zoocdn.com/db1074144fdc6bf06d02224d09fa588ba1545fb1.gif


### Building the Flutter app on docker

1. `export TAG=0.1` or whichever version you are on
1. `export ZOOPLAAPIKEY=<your key>`
1. `docker build . --build-arg ZOOPLAAPIKEY=$ZOOPLAAPIKEY -f FlutterDockerfile -t home_search_web:$TAG`
1. `docker run -d --name web -p 5001:5001 home_search_web:$TAG`

## Server Deployment (Heroku)
1. Create an app
`heroku create homesearch2021`

1. Log into heroku:
`heroku container:login`

1. Build the images locally. This builds three images: `home-search_backend`, `home-search_frontend`, `postgres`
`docker compose up`

1. Tag the images:
   ```bash
   docker tag home-search_backend registry.heroku.com/homesearch2021/api
   docker tag home-search_frontend registry.heroku.com/homesearch2021/web
   ```

1. Push to Heroku (wait for first to complete):
   ```bash
   docker push registry.heroku.com/homesearch2021/api
   docker push registry.heroku.com/homesearch2021/web
   ```

1. Release the image
   ```bash
   heroku container:release --app homesearch2021 api
   heroku container:release --app homesearch2021 web
   ```

1. open the app
`heroku open --app homesearch2021`
