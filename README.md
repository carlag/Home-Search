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

### Set up the environment

If you haven't already:

1. `python3 -m venv .env`
1. `source .env/bin/activate`
1. `pip install -r requirements.txt`

### Running the service

1. `cd ocr_service`
1. `uvicorn main:app --reload`

### Calling the service

1. send a request to where ever the service is running (e.g. `http://127.0.0.1:8000`) followed by `/image/{image_file}`.
   e.g. `curl http://127.0.0.1:8000/image/f9bcacc95fcbeb8e7490ad7cc6726f667785b6e2.jpg`
