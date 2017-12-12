source /opt/DL/tensorflow/bin/tensorflow-activate
DATA_DIR="${1%/}"
SCRATCH_DIR="${DATA_DIR}/raw-data/"
WORK_DIR="/gpfs/gpfs_gl4_16mb/b7p284za/models/research/inception/inception"


TRAIN_DIRECTORY="${SCRATCH_DIR}train/"
VALIDATION_DIRECTORY="${SCRATCH_DIR}validation/"

BOUNDING_BOX_SCRIPT="${WORK_DIR}/data/process_bounding_boxes.py"
BOUNDING_BOX_FILE="${SCRATCH_DIR}/imagenet_2012_bounding_boxes.csv"
BOUNDING_BOX_DIR="${SCRATCH_DIR}bounding_boxes/"

# Preprocess the validation data by moving the images into the appropriate
# sub-directory based on the label (synset) of the image.
echo "Organizing the validation data into sub-directories."
PREPROCESS_VAL_SCRIPT="${WORK_DIR}/data/preprocess_imagenet_validation_data.py"
VAL_LABELS_FILE="${WORK_DIR}/data/imagenet_2012_validation_synset_labels.txt"

"${PREPROCESS_VAL_SCRIPT}" "${VALIDATION_DIRECTORY}" "${VAL_LABELS_FILE}"

# Convert the XML files for bounding box annotations into a single CSV.
echo "Extracting bounding box information from XML."
BOUNDING_BOX_SCRIPT="${WORK_DIR}/data/process_bounding_boxes.py"
BOUNDING_BOX_FILE="${SCRATCH_DIR}/imagenet_2012_bounding_boxes.csv"
BOUNDING_BOX_DIR="${SCRATCH_DIR}bounding_boxes/"
LABELS_FILE="${WORK_DIR}/data/imagenet_lsvrc_2015_synsets.txt"


"${BOUNDING_BOX_SCRIPT}" "${BOUNDING_BOX_DIR}" "${LABELS_FILE}" \
 | sort > "${BOUNDING_BOX_FILE}"
echo "Finished downloading and preprocessing the ImageNet data."

# Build the TFRecords version of the ImageNet data.
BUILD_SCRIPT="/usr/bin/python ${WORK_DIR}/data/build_imagenet_data.py"
OUTPUT_DIRECTORY="${DATA_DIR}/ilsvrc_tf"
mkdir -p "${DATA_DIR}/ilsvrc_tf"
IMAGENET_METADATA_FILE="${WORK_DIR}/data/imagenet_metadata.txt"

python /gpfs/gpfs_gl4_16mb/b7p284za/models/research/inception/inception/data/build_imagenet_data.py \
  --train_directory="${TRAIN_DIRECTORY}" \
  --validation_directory="${VALIDATION_DIRECTORY}" \
  --output_directory="${OUTPUT_DIRECTORY}" \
  --imagenet_metadata_file="${IMAGENET_METADATA_FILE}" \
  --labels_file="${LABELS_FILE}" \
  --bounding_box_file="${BOUNDING_BOX_FILE}"
