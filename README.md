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

ou can either deploy is via docker or manually

### Deploy with Docker

Create an environment variable with a version number
```
export TAG=0.1
```

Build the image:
```bash
docker build . -f OCRDockerfile -t home_search_ocr:$TAG
```

Run the container:
```bash
docker run -d --name ocr -p 80:80 home_search_ocr:$TAG
```

Test it
### Calling the service

```bash
curl localhost/jpg/f9bcacc95fcbeb8e7490ad7cc6726f667785b6e2
curl localhost/pdf/acf057f7f02b0cf3552e149de5772640bf0bfd2c
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
   e.g. `curl http://127.0.0.1:8000/jpg/f9bcacc95fcbeb8e7490ad7cc6726f667785b6e2` or
   `curl http://127.0.0.1:8000/pdf/acf057f7f02b0cf3552e149de5772640bf0bfd2c`
