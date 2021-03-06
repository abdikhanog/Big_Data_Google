export PROJECT=$(gcloud config list project --format "value(core.project)")
export BUCKET="gs://${PROJECT}-ml"
export GCS_PATH="${BUCKET}/${USER}/${JOB_ID}"
export DICT_FILE=gs://cloud-samples-data/ml-engine/flowers/dict.txt

# Then we access the relevant folder-------------------------
cd cloudml-samples/flowers/


# ----- HIGHCPU16, DROPOUT = 0.1 -----------------------------------------------------------------------

# Define job id and model details
export JOB_ID="CPUwithDRopout_${USER}"
export MODEL_NAME=CPUwithDRopout
export VERSION_NAME=v1

gcloud beta ml-engine jobs submit training "$JOB_ID" \
 --stream-logs \
 --module-name trainer.task \
 --package-path trainer \
 --staging-bucket "$BUCKET" \
 --region us-east1 \
 --runtime-version=1.10 \
 --scale-tier custom \
 --master-machine-type n1-highcpu-16 \
 -- \
 --dropout=0.1 \
 --max_steps=5000 \
 --output_path "${GCS_PATH}/training" \
 --eval_data_paths "${BUCKET}/${USER}/flowers_${USER}/preproc/eval*" \
 --train_data_paths "${BUCKET}/${USER}/flowers_${USER}/preproc/train*"

gcloud ml-engine models create "$MODEL_NAME" \
 --regions us-east1

gcloud ml-engine versions create "$VERSION_NAME" \
 --model "$MODEL_NAME" \
 --origin "${GCS_PATH}/training/model" \
 --runtime-version=1.10


#---------------------HIGHCPU-16,dropout = 0.5-------------------------------------------------

# Define job id and model details
export JOB_ID="cpuWITHdropout_${USER}"
export MODEL_NAME=cpuWITHdropout
export VERSION_NAME=v1

gcloud beta ml-engine jobs submit training "$JOB_ID" \
 --stream-logs \
 --module-name trainer.task \
 --package-path trainer \
 --staging-bucket "$BUCKET" \
 --region us-east1 \
 --runtime-version=1.10 \
 --scale-tier custom \
 --master-machine-type n1-highcpu-16 \
 -- \
 --dropout=0.5 \
 --max_steps=5000 \
 --output_path "${GCS_PATH}/training" \
 --eval_data_paths "${BUCKET}/${USER}/flowers_${USER}/preproc/eval*" \
 --train_data_paths "${BUCKET}/${USER}/flowers_${USER}/preproc/train*"

gcloud ml-engine models create "$MODEL_NAME" \
 --regions us-east1

gcloud ml-engine versions create "$VERSION_NAME" \
 --model "$MODEL_NAME" \
 --origin "${GCS_PATH}/training/model" \
 --runtime-version=1.10


#---------------------HIGHCPU-16,dropout = 0.9-------------------------------------------------

# Define job id and model details
export JOB_ID="CPUWithDROPOUT_${USER}"
export MODEL_NAME=CPUWithDROPOUT
export VERSION_NAME=v1

gcloud beta ml-engine jobs submit training "$JOB_ID" \
 --stream-logs \
 --module-name trainer.task \
 --package-path trainer \
 --staging-bucket "$BUCKET" \
 --region us-east1 \
 --runtime-version=1.10 \
 --scale-tier custom \
 --master-machine-type n1-highcpu-16 \
 -- \
 --dropout=0.9 \
 --max_steps=5000 \
 --output_path "${GCS_PATH}/training" \
 --eval_data_paths "${BUCKET}/${USER}/flowers_${USER}/preproc/eval*" \
 --train_data_paths "${BUCKET}/${USER}/flowers_${USER}/preproc/train*"

gcloud ml-engine models create "$MODEL_NAME" \
 --regions us-east1

gcloud ml-engine versions create "$VERSION_NAME" \
 --model "$MODEL_NAME" \
 --origin "${GCS_PATH}/training/model" \
 --runtime-version=1.10