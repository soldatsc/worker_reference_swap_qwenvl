FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes
RUN comfy-node-install \
    rgthree-comfy \
    comfyui-easy-use \
    comfyui-custom-scripts \
    comfyui-detail-daemon \
    comfyui-kjnodes

# Install nodes that need git clone
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/Gourieff/ComfyUI-ReActor && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack && \
    git clone https://github.com/1038lab/ComfyUI-QwenVL && \
    git clone https://github.com/WASasquatch/was-node-suite-comfyui

# Install Python dependencies
RUN pip install --no-cache-dir \
    ultralytics \
    insightface \
    onnxruntime \
    scikit-image \
    numba \
    piexif \
    gguf \
    segment-anything \
    dill \
    blend-modes \
    accelerate

# Install requirements for each node
RUN cd /comfyui/custom_nodes/ComfyUI-ReActor && pip install --no-cache-dir -r requirements.txt || true && \
    cd /comfyui/custom_nodes/ComfyUI-Impact-Pack && pip install --no-cache-dir -r requirements.txt || true && \
    cd /comfyui/custom_nodes/ComfyUI-Impact-Subpack && pip install --no-cache-dir -r requirements.txt || true && \
    cd /comfyui/custom_nodes/ComfyUI-QwenVL && pip install --no-cache-dir -r requirements.txt || true && \
    cd /comfyui/custom_nodes/was-node-suite-comfyui && pip install --no-cache-dir -r requirements.txt || true

# Download VAE
RUN comfy model download \
    --url https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors \
    --relative-path models/vae \
    --filename ae.safetensors

# Download CLIP
RUN mkdir -p /comfyui/models/clip/ZIT && \
    wget -O /comfyui/models/clip/ZIT/qwen_3_4b.safetensors \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"

# Download ZIT UNET (public repo)
RUN mkdir -p /comfyui/models/unet && \
    wget -O /comfyui/models/unet/2602_ZIT_BSY_fp8_scaled-c63.safetensors \
    "https://huggingface.co/soldatsc/zit-bsy-model/resolve/main/2602_ZIT_BSY_fp8_scaled-c63.safetensors"

# Download ReActor models
RUN mkdir -p /comfyui/models/insightface && \
    wget -O /comfyui/models/insightface/inswapper_128.onnx \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/inswapper_128.onnx"

RUN mkdir -p /comfyui/models/facerestore_models && \
    wget -O /comfyui/models/facerestore_models/codeformer-v0.1.0.pth \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/codeformer-v0.1.0.pth"

# Download buffalo_l face detection models
RUN mkdir -p /comfyui/models/insightface/models/buffalo_l && \
    cd /tmp && \
    wget https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_l.zip && \
    python3 -c "import zipfile; zipfile.ZipFile('buffalo_l.zip').extractall('/comfyui/models/insightface/models/')" && \
    rm buffalo_l.zip && \
    mv /comfyui/models/insightface/models/*.onnx /comfyui/models/insightface/models/buffalo_l/ 2>/dev/null || true

# Download ultralytics face detection for FaceDetailer
RUN mkdir -p /comfyui/models/ultralytics/bbox && \
    wget -O /comfyui/models/ultralytics/bbox/face_yolov8m.pt \
    "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/detection/bbox/face_yolov8m.pt"
