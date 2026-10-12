# Notas del proceso - Clasificador de animales con Azure Custom Vision

Fecha de inicio: 2026-10-11

## 1. Suscripción
- Tipo: Azure for Students (crédito 100 USD, vence 2027-10-11).
- Cuenta: correo institucional @unisalle.edu.co (tenant Universidad de La Salle).
- Sin tarjeta de crédito.

## 2. Recurso Azure AI Services
- Grupo de recursos: rg-animal-vision (nuevo).
- Nombre del recurso: ai-animal-identification.
- Región: West US 2.
  - East US (la indicada en la guía) fue rechazada por la política de la suscripción
    (error RequestDisallowedByAzure: "This policy maintains a set of best available
    regions where your subscription can deploy resources").
- Plan de tarifa: Standard S0 (único disponible para el recurso multiservicio).
- Red: todas las redes. Identity: None.
- Términos de IA responsable aceptados.
- Implementación: CognitiveServicesAllInOne-20261011162827, iniciada 11/10/2026 16:30, completada en ~30 s.
- Estado: Activo. Tipo de API: CognitiveServices.
- Endpoint: https://ai-animal-identification.cognitiveservices.azure.com/
- Región del recurso: westus2. El grupo de recursos quedó en East US (se creó en el primer intento), lo cual no afecta.
- Claves: Key1/Key2 disponibles en "Claves y punto de conexión" (no se copian al informe).
- Capturas: assets/images/screenshots/azure/01 a 11.

## 3. Proyecto Custom Vision
- Portal: https://www.customvision.ai (términos de servicio aceptados el 2026-10-11).
- Name: Animal Identification.
- Description: Image classification for animals.
- Resource: ai-animal-identification [S0].
- Project Type: Classification. Classification Type: Multiclass (single tag per image).
- Domain: General [A2].
- Project ID: 292060af-4805-412b-b544-df9926ffc462
- Endpoint de entrenamiento: https://ai-animal-identification.cognitiveservices.azure.com/
- Límites S0 mostrados: 100000 imágenes, 500 tags, 20 iteraciones, 100 proyectos.
- Capturas: azure/12 a 16 (en la 16 se tapó la clave).

## 4. Dataset
- Fuente: laboratorio Microsoft Learn AI-900 "Explore image classification"
  (https://microsoftlearning.github.io/AI-900-AIFundamentals/instructions/03a-classify-images.html),
  enlace aka.ms/animal-images que apunta a
  https://github.com/MicrosoftLearning/AI-900-AIFundamentals/raw/main/data/vision/animals/animals.zip (6.5 MB).
- Ubicación local: dataset/ (zip original + carpetas elephant/, giraffe/, lion/).
- 51 imágenes JPG, 17 por clase, ~365 px en el lado mayor, todas verificadas con PIL (0 corruptas).
- Nombres originales PictureNN.jpg.

## 5. Carga, etiquetado y entrenamiento
- Carga por lotes desde el portal (Add images), un lote por clase, etiqueta asignada en el diálogo:
  elephant (17), giraffe (17), lion (17). Total 51 imágenes etiquetadas, 0 sin etiqueta.
- Entrenamiento: botón Train > Quick Training (presupuesto mínimo estimado 1 hora, no se usa).
- Iteration 1 iniciada el 11/10/2026 a las 16:41.
- Capturas: azure/17 a 26.

## 5b. Métricas y pruebas rápidas
- Iteration 1 terminó el 11/10/2026 a las 16:47:58 (~6 min), dominio General [A2], Multiclass.
- Iteration id: ad454c83-4f99-4895-986e-5d00065bbb74
- Umbral de probabilidad: 50 % (por defecto).
- Métricas globales: Precision 100.0 %, Recall 100.0 %, AP 100.0 %.
- Por etiqueta (17 imágenes c/u): lion 100/100/100, giraffe 100/100/100, elephant 100/100/100.
  Nota para el análisis: con 51 imágenes el portal valida con una partición interna pequeña,
  así que el 100 % refleja un dataset limpio y bien separado, no garantiza generalización.
- Quick Test con 3 imágenes externas (Wikimedia Commons, ver dataset/test/FUENTES.md):
  | Imagen | Predicción | elephant | giraffe | lion |
  |---|---|---|---|---|
  | test_elephant.jpg | elephant | 97.6 % | 1.6 % | 0.7 % |
  | test_giraffe.jpg | giraffe | 1.3 % | 98.4 % | 0.2 % |
  | test_lion.jpg | lion | 0 % | 0 % | 99.9 % |
- Capturas: azure/27 a 33.

## 6. Publicación
- Publicada el 11/10/2026 ~16:53 desde Performance > Publish.
- Model name: animal-classifier. Prediction resource: ai-animal-identification (misma región westus2).
- Iteration 1 queda marcada PUBLISHED.
- Prediction URL (imagen por URL, Content-Type application/json, body {"Url": "..."}):
  https://ai-animal-identification.cognitiveservices.azure.com/customvision/v3.0/Prediction/292060af-4805-412b-b544-df9926ffc462/classify/iterations/animal-classifier/url
- Prediction URL (imagen por archivo, Content-Type application/octet-stream):
  https://ai-animal-identification.cognitiveservices.azure.com/customvision/v3.0/Prediction/292060af-4805-412b-b544-df9926ffc462/classify/iterations/animal-classifier/image
- Header de autenticación: Prediction-Key (clave del recurso, NO se guarda en el informe).
- Capturas: azure/34 a 37 (en la 37 se tapó la clave).

## 7. Cliente de línea de comandos (Azure Cloud Shell)
- Cloud Shell en Bash, modo "sin cuenta de almacenamiento" (sesión efímera, no crea recursos).
- Aviso al iniciar: la suscripción no está registrada en Microsoft.CloudShell; funciona igual en modo efímero.
- Autenticación: la Prediction-Key se obtuvo con
  `az cognitiveservices account keys list -g rg-animal-vision -n ai-animal-identification --query key1 -o tsv`
  directamente a una variable de shell (nunca se imprimió). Al final: unset KEY; history -c.
- Script completo: animal-identification-report/utils/codes/model-predict/predict_cloudshell.sh
- Resultados (JSON): animal-identification-report/utils/codes/model-predict/cloudshell_results.json
  | Prueba | Modo | Predicción | Probabilidad |
  |---|---|---|---|
  | Lion_waiting_in_Namibia.jpg | URL (application/json) | lion | 0.99908 |
  | elephant.jpg | archivo (octet-stream) | elephant | 0.97605 |
  | giraffe.jpg | archivo (octet-stream) | giraffe | 0.98417 |
- Capturas: azure/38 a 41.

## 8. Informe
- LaTeX IEEEtran en animal-identification-report/ (contenido anterior respaldado en _respaldo-informe-carnivoras/ y en el historial git).
- Compilación: bash animal-identification-report/build.sh (pdflatex + bibtex con BIBINPUTS + 2 pdflatex). latexmk falla porque MiKTeX ejecuta bibtex dentro de build/.
- Resultado: build/main.pdf, 9 páginas, 17 referencias, 20 figuras, 6 tablas, 2 listados. Copia en la raíz:
  "Informe - Clasificacion de animales con Azure Custom Vision - Andy Rubiano.pdf".
- Advertencias restantes: 2 overfull de 20 pt en los listados (invisibles, el recuadro cabe en la columna).

## 9. Después de la calificación
- El grupo de recursos rg-animal-vision se conserva activo mientras se evalúa la actividad (costo de centavos).
- Borrarlo después es opcional; si se borra se pierden proyecto, imágenes y modelo, y recrearlos genera IDs nuevos.
