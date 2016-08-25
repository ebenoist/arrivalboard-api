APP_NAME="ab"
REPOSITORY="ebenoist/arrivalboard-api"
DEPLOY_USER="ebenoist"
RUN_CMD="docker run -d \
  -e ENV=${ENV} \
  -e TT_KEY=${TT_KEY} \
  -e BUS_KEY=${BUS_KEY} \
  -e RTD_USER=${RTD_USER} \
  -e RTD_PASS=${RTD_PASS} \
  --link ab-mongo:mongo -p 8080:3000 \
  --name ab ebenoist/arrivalboard-api:release"
