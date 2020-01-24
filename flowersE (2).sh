export PROJECT=$(gcloud config list project --format "value(core.project)")
export BUCKET="gs://${PROJECT}-ml"
export GCS_PATH="${BUCKET}/${USER}/${JOB_ID}"
export DICT_FILE=gs://cloud-samples-data/ml-engine/flowers/dict.txt

# Then we access the relevant folder-------------------------
cd cloudml-samples/flowers/


# ----- HIGHCPU16 -----------------------------------------------------------------------

# Define job id and model details
export JOB_ID="Flowers_highCPU_16_${USER}"
export MODEL_NAME=Flowers_highCPU_16
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

# ----- complex_model_s-8 CPU ----------------------------------------------------

# Define job id and model details
export JOB_ID="flowers_complex_model_s_${USER}"
export MODEL_NAME=flowers_complex_model_s
export VERSION_NAME=v1

gcloud beta ml-engine jobs submit training "$JOB_ID" \
 --stream-logs \
 --module-name trainer.task \
 --package-path trainer \
 --staging-bucket "$BUCKET" \
 --region us-east1 \
 --runtime-version=1.10 \
 --scale-tier custom \
 --master-machine-type complex_model_s \
 -- \
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

# ----- STANDARDGPU -----

# Define job id and model details
export JOB_ID="flowers_standardGPU_${USER}"
export MODEL_NAME=flowers_standardGPU
export VERSION_NAME=v1

cd cloudml-samples/flowers/

gcloud beta ml-engine jobs submit training "$JOB_ID" \
 --stream-logs \
 --module-name trainer.task \
 --package-path trainer \
 --staging-bucket "$BUCKET" \
 --region us-east1 \
 --runtime-version=1.10 \
 --scale-tier custom \
 --master-machine-type standard_gpu \
 -- \
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

# -----Tesla_GPU-----

# Define job id and model details
export JOB_ID="Flowers_tesla1_GPU_${USER}"
export MODEL_NAME=Flowers_tesla1_GPU
export VERSION_NAME=v1

gcloud beta ml-engine jobs submit training "$JOB_ID" \
 --stream-logs \
 --module-name trainer.task \
 --package-path trainer \
 --staging-bucket "$BUCKET" \
 --region us-east1 \
 --runtime-version=1.10 \
 --scale-tier custom \
 --master-machine-type standard_p100 \
 -- \
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
