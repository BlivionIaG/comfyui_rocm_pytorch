ARG IMAGE_VERSION="0.0.1"

ARG BASE_IMAGE="docker.io/rocm/pytorch"
ARG BASE_IMAGE_VERSION="rocm7.1_ubuntu24.04_py3.12_pytorch_release_2.8.0"

FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION}


ARG COMFYUI_VERSION="v0.3.71"
ARG COMFYUI_MANAGER_VERSION="3.37.1"
ARG COMFY_CLI_VERSION="1.5.3"

ARG APP_DIR="/app"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Instal uv
RUN pip install --no-cache-dir uv

# Clone comfyui from github repository 
RUN git clone --branch ${COMFYUI_VERSION} https://github.com/comfyanonymous/ComfyUI.git ${APP_DIR} && \
    cd ${APP_DIR} && \
    pip install --no-cache-dir -r requirements.txt

# Install comfy-cli
RUN pip install --no-cache-dir comfy-cli==${COMFY_CLI_VERSION}

# Install ComfyUI-Manager module
RUN git clone --branch ${COMFYUI_MANAGER_VERSION} https://github.com/Comfy-Org/ComfyUI-Manager.git ${APP_DIR}/custom_nodes/comfyui-manager && \
    cd ${APP_DIR}/custom_nodes/comfyui-manager && \
    pip install --no-cache-dir -r requirements.txt

# Set working directory
WORKDIR ${APP_DIR}

VOLUME ${APP_DIR}/models
VOLUME ${APP_DIR}/output
VOLUME ${APP_DIR}/user/default/workflows

EXPOSE 8188

LABEL maintainer="BlivionIaG <kev29lt@gmail.com>" \
    version="${IMAGE_VERSION}" \
    description="ComfyUI with ROCm support"

CMD ["python3", "main.py", "--listen", "0.0.0.0"]
