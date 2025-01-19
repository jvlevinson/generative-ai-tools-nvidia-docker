#!/bin/bash
# https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Optimum-SDXL-Usage
# https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Optimizations

# Validate environment variables
validate_env_var() {
  local var_name="$1"
  local var_value="$2"
  if [[ "$var_value" != "true" && "$var_value" != "false" ]]; then
    echo "Error: Invalid value for $var_name. Expected 'true' or 'false', got '$var_value'."
    exit 1
  fi
}

validate_env_var "IS_LOWVRAM" "$IS_LOWVRAM"
validate_env_var "IS_MEDVRAM" "$IS_MEDVRAM"
validate_env_var "USE_XFORMERS" "$USE_XFORMERS"
validate_env_var "USE_CUDA_118" "$USE_CUDA_118"

export COMMANDLINE_ARGS="$COMMANDLINE_ARGS --listen"

if [ "$IS_LOWVRAM" = "true" ]; then
  export COMMANDLINE_ARGS="$COMMANDLINE_ARGS --lowvram --opt-split-attention"
elif [ "$IS_MEDVRAM" = "true" ]; then
  export COMMANDLINE_ARGS="$COMMANDLINE_ARGS --medvram --opt-sdp-attention"
fi

export LD_PRELOAD=libtcmalloc.so

echo "Using standard Linux configuration"
if [ "$USE_CUDA_118" = "true" ]; then
  echo "Using CUDA 118"
  export TORCH_COMMAND="pip install torch==2.1.0+cu118 torchvision==0.16.0+cu118 --extra-index-url https://download.pytorch.org/whl/cu118"
fi

if [ "$USE_XFORMERS" = "true" ]; then
    echo "Using XFormers" 
    export COMMANDLINE_ARGS="$COMMANDLINE_ARGS --xformers"
else 
   echo "Not using XFormers" 
fi

echo "Command line args = ${COMMANDLINE_ARGS}"

# Add logging
log_file="/var/log/webui-user.log"
exec > >(tee -a "$log_file") 2>&1

# Implement monitoring (simple example)
monitoring_file="/var/log/webui-user-monitoring.log"
echo "$(date): Script executed" >> "$monitoring_file"
