# Start processing some coastline images.
export PROJECT=$(gcloud config list project --format "value(core.project)")
export JOB_ID="coastline_${USER}"
export BUCKET="gs://${PROJECT}-ml"
export GCS_PATH="${BUCKET}/${USER}/${JOB_ID}"
export MODEL_NAME=coastline
export VERSION_NAME=v1

# Get coastline data from relevant location
gsutil cp gs://tamucc_coastline/dict.txt . ${BUCKET}
gsutil cp gs://tamucc_coastline/dict_explanation.csv . ${BUCKET}
gsutil cp gs://tamucc_coastline/labels.csv . ${BUCKET}
gsutil cp gs://tamucc_coastline/labeled_images.csv . ${BUCKET}

# Set labels dictionary (stored in bucket)
export DICT_FILE=${BUCKET}/dict.txt

# Create coastline folder in cloudml-samples folder
cd cloudml-samples
mkdir coastline

# Create trainer folder within coastline folder to store relevant python files
cd coastline
mkdir trainer

# Copy python files from flowers/trainer/ folder to coastline/trainer/
cd
gsutil cp cloudml-samples/flowers/trainer/* cloudml-samples/coastline/trainer/

cd cloudml-samples/coastline/

# Preprocess evaluation set
python trainer/preprocess.py \
--input_dict "$DICT_FILE" \
--input_path "${BUCKET}/eval_set.csv" \
--output_path "${GCS_PATH}/preproc/eval" \
--job_name "coastline-eval" \
--cloud

# Preprocess train set
python trainer/preprocess.py \
--input_dict "$DICT_FILE" \
--input_path "${BUCKET}/train_set.csv" \
--output_path "${GCS_PATH}/preproc/train" \
--job_name "coastline-train" \
--cloud

# Training on CloudML is quick after preprocessing.  If you ran the above
# commands asynchronously, make sure they have completed before calling this one.
gcloud ml-engine jobs submit training "$JOB_ID" \
 --stream-logs \
 --module-name trainer.task \
 --package-path trainer \
 --staging-bucket "$BUCKET" \
 --region us-central1 \
 --runtime-version=1.10 \
 -- \
 --max_steps=5000 \
 --eval_set_size=2343 \
 --label_count=18 \
 --output_path "${GCS_PATH}/training" \
 --eval_data_paths "${GCS_PATH}/preproc/eval*" \
 --train_data_paths "${GCS_PATH}/preproc/train*"

# Alert gcloud of new model
gcloud ml-engine models create "$MODEL_NAME" \
  --regions us-central1

# Create model with $MODEL_NAME and vesrion with $VERSION_NAME
# Creating a version actually deploys our Tensorflow graph to a Cloud instance, and gets is ready to serve (predict)
gcloud ml-engine versions create "$VERSION_NAME" \
  --model "$MODEL_NAME" \
  --origin "${GCS_PATH}/training/model" \
  --runtime-version=1.10

cd

# gsutil cp gs://tamucc_coastline/esi_images/IMG_2839_SecHKL_Sum12_Pt2.jpg cloudml-samples/coastline/
# The line above will retrieve the relevant JPEG for prediction; this image has been compressed and saved to the bucket

gsutil cp ${BUCKET}/Coastline_Prediction_Test.jpg cloudml-samples/coastline/

# python -c 'import base64, sys, json; img = base64.b64encode(open(sys.argv[1], "rb").read()); print json.dumps({"key":"6A", "image_bytes": {"b64": img}})' Coastline_Prediction_Test.jpg &> request.json

# cd cloudml-samples/coastline/

# gcloud ml-engine predict --model ${MODEL_NAME} --json-instances request.json

# COMMENT: run code from line 81 to line 87 from the cloud shell separately to get existing model prediction on Coastline_Prediction_Test.jpg.
