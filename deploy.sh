export API_NAME=${APP_NAME}server
export URL_API=https://${API_NAME}.herokuapp.com
heroku container:login
docker compose up -d
docker compose down
docker tag home-search_backend registry.heroku.com/$API_NAME/web
docker tag home-search_frontend registry.heroku.com/$APP_NAME/web
docker push registry.heroku.com/$API_NAME/web
docker push registry.heroku.com/$APP_NAME/web
heroku container:release --app $API_NAME web
heroku container:release --app $APP_NAME web
heroku ps:scale --app $API_NAME web=0
heroku ps:scale --app $APP_NAME web=0
heroku ps:scale --app $API_NAME web=1
heroku ps:scale --app $APP_NAME web=1
heroku open --app $APP_NAME
