# Processes some flowers images.
export PROJECT=$(gcloud config list project --format "value(core.project)")
export JOB_ID="flowers_${USER}"
export BUCKET="gs://${PROJECT}-ml"
export GCS_PATH="${BUCKET}/${USER}/${JOB_ID}"
export DICT_FILE=gs://cloud-samples-data/ml-engine/flowers/dict.txt
export MODEL_NAME=flowers
export VERSION_NAME=v1

# Create bucket
gsutil mb gs://${PROJECT}-ml

# Get flowers data from github
git clone https://github.com/GoogleCloudPlatform/cloudml-samples
# Move to flowers directory
cd cloudml-samples/flowers/

# install apache-beam and pillow packages
pip install --user apache-beam[gcp]
pip install --user pillow

# Preprocess evaluation set 
python trainer/preprocess.py \
 --input_dict "$DICT_FILE" \
 --input_path "gs://cloud-samples-data/ml-engine/flowers/eval_set.csv" \
 --output_path "${GCS_PATH}/preproc/eval" \
 --job_name "flowers-eval" \
 --cloud

# Preprocess train set
python trainer/preprocess.py \
 --input_dict "$DICT_FILE" \
 --input_path "gs://cloud-samples-data/ml-engine/flowers/train_set.csv" \
 --output_path "${GCS_PATH}/preproc/train" \
 --job_name "flowers-train" \
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

# Move to flowers directory
cd 
cd cloudml-samples/flowers/

# Download a daisy jpeg so we can test online prediction.
gsutil cp \
  gs://cloud-samples-data/ml-engine/flowers/daisy/100080576_f52e8ee070_n.jpg \
  daisy.jpg

# For prediction cannot run from sh file, must type below codes directly into shell command. 

# cd cloudml-samples/flowers/
# export MODEL_NAME=flowers

# Since the image is passed via JSON, we have to encode the JPEG string first.
# python -c 'import base64, sys, json; img = base64.b64encode(open(sys.argv[1], "rb").read()); print json.dumps({"key":"0", "image_bytes": {"b64": img}})' daisy.jpg &> request.json

# Request a prediction from the cloud service
# gcloud ml-engine predict --model ${MODEL_NAME} --json-instances request.json
# PREDICTION 
# KEY  PREDICTION  SCORES
# 0    0           [0.9999938011169434, 3.0807714779257367e-07, 1.3980688891024329e-06, 3.826646661764244e-06, 4.0456370697938837e-07, 2.7321334528096486e-07]

