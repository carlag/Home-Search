# proper_house_search

Proper House Search

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


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