variable "REGISTRY_REPO_NAME" {
    default = "blivioniag/comfyui_rocm_pytorch"
}

variable "IMAGE_VERSION" {
    default = "0.0.1"
}

variable "COMFYUI_VERSION" {
    default = "v0.3.71"
}

variable "COMFYUI_MANAGER_VERSION" {
    default = "3.37.1"
}

variable "COMFY_CLI_VERSION" {
    default = "1.5.3"
}

variable "BASE_IMAGE" {
    default = "docker.io/rocm/pytorch"
}

function "default_tag" {
    params = [tag]
    result = [
        "${REGISTRY_REPO_NAME}:${tag}",
        "${REGISTRY_REPO_NAME}:${tag}-comfyui${COMFYUI_VERSION}",
        "${REGISTRY_REPO_NAME}:comfyui${COMFYUI_VERSION}"
    ]
}

function "other_tag" {
    params = [tag, rocm]
    result = [
        "${REGISTRY_REPO_NAME}:${tag}-${rocm}",
        "${REGISTRY_REPO_NAME}:${tag}-comfyui${COMFYUI_VERSION}-${rocm}",
        "${REGISTRY_REPO_NAME}:comfyui${COMFYUI_VERSION}-${rocm}",
        "${REGISTRY_REPO_NAME}:${rocm}",
    ]
}



target "_common" {
    dockerfile = "Dockerfile"
    context = "."
    args = {
        COMFYUI_VERSION = COMFYUI_VERSION
        COMFYUI_MANAGER_VERSION = COMFYUI_MANAGER_VERSION
        COMFY_CLI_VERSION = COMFY_CLI_VERSION
        IMAGE_VERSION = IMAGE_VERSION
    }
}

target "rocm710" {
    extends = ["_common"]
    args = {
        BASE_IMAGE = BASE_IMAGE
        BASE_IMAGE_VERSION = "rocm7.1_ubuntu24.04_py3.12_pytorch_release_2.8.0"
    }
    tags = concat(default_tag(IMAGE_VERSION), other_tag(IMAGE_VERSION, "rocm7.1"))
}

target "rocm644" {
    extends = ["_common"]
    args = {
        BASE_IMAGE = BASE_IMAGE
        BASE_IMAGE_VERSION = "rocm6.4.4_ubuntu24.04_py3.12_pytorch_release_2.7.1"
    }
    tags = other_tag(IMAGE_VERSION, "rocm6.4.4")
}
    
target "gfx906" {
    extends = ["_common"]
    args = {
        BASE_IMAGE = "docker.io/mixa3607/pytorch-gfx906"
        BASE_IMAGE_VERSION = "v2.9.0-rocm-7.0.2"
    }
    tags = other_tag(IMAGE_VERSION, "gfx906")
}
