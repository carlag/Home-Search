#!/bin/bash

# Welcome
echo 'Server start script initialized...'

# Kill anything that is already running on that port
echo 'Cleaning port' $PORT '...'
fuser -k $PORT/tcp

# Change directories to the release folder
cd build/web/

sed -i.bkp "s/<GOOGLEMAPSAPIKEY>/$GOOGLEMAPSAPIKEY/" index.html
sed -i.bkp "s/<CLIENT_ID>/$CLIENT_ID/" index.html

# Start the server
echo 'Starting server on port' $PORT '...'
python3 -m http.server $PORT

# Exit
echo 'Server exited...'

mv index.html.bkp index.html
cd ../..