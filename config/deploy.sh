APP_NAME="ab"
REPOSITORY="ebenoist/arrivalboard-api"
DEPLOY_USER="deploy"
RUN_CMD= "docker run -d \
  -e ENV=${ENV} \
  -e TT_KEY=${TT_KEY} \
  -e BUS_KEY=${BUS_KEY} \
  --link ab-mongo:mongo -p 8080:3000 \
  --name ab ebenoist/arrivalboard-api:release"
