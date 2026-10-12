#!/usr/bin/env bash
# Cliente de linea de comandos para el modelo publicado en Azure Custom Vision.
# Ejecutado en Azure Cloud Shell (Bash). La clave se obtiene con Azure CLI y
# nunca se escribe en pantalla ni en el informe.

RG=rg-animal-vision
RES=ai-animal-identification
PID=292060af-4805-412b-b544-df9926ffc462
MODEL=animal-classifier

az account show --query name -o tsv
KEY=$(az cognitiveservices account keys list -g "$RG" -n "$RES" --query key1 -o tsv)
BASE="https://$RES.cognitiveservices.azure.com/customvision/v3.0/Prediction/$PID/classify/iterations/$MODEL"

# Prueba 1: imagen por URL
curl -s -X POST "$BASE/url" \
  -H "Prediction-Key: $KEY" -H "Content-Type: application/json" \
  -d '{"Url":"https://upload.wikimedia.org/wikipedia/commons/7/73/Lion_waiting_in_Namibia.jpg"}' | jq .

# Prueba 2 y 3: imagen por archivo (octet-stream)
UA='Mozilla/5.0'
curl -sL -A "$UA" -o elephant.jpg 'https://commons.wikimedia.org/wiki/Special:FilePath/African_Bush_Elephant.jpg?width=1024'
curl -sL -A "$UA" -o giraffe.jpg  'https://commons.wikimedia.org/wiki/Special:FilePath/Makalali_Game_Reserve_(ZA),_Giraffe_--_2024_--_1124.jpg?width=1024'
for f in elephant giraffe; do
  echo "== $f.jpg"
  curl -s -X POST "$BASE/image" \
    -H "Prediction-Key: $KEY" -H "Content-Type: application/octet-stream" \
    --data-binary @"$f.jpg" | jq -c '.predictions[] | {tagName, probability}'
done
