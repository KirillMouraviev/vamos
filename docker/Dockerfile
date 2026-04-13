# Dockerfile for VAMOS with ROS Noetic, CUDA 12.1, and Conda

FROM nvcr.io/nvidia/cuda:12.1.1-cudnn8-devel-ubuntu20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# Set environment variables for ROS and Conda
ENV ROS_DISTRO=noetic
ENV ROS_PYTHON_VERSION=3
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Install system dependencies for ROS Noetic and Conda
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    libbluetooth-dev \
    libcwiid-dev \
    libgoogle-glog-dev \
    libasio-dev \
    libtinyxml2-dev \
    libeigen3-dev \
    libboost-all-dev \
    libyaml-cpp-dev \
    libopencv-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-catkin-pkg \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda (lightweight Anaconda alternative)
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh && \
    $CONDA_DIR/bin/conda clean -tip && \
    ln -s $CONDA_DIR/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc

# Set up ROS workspace
ENV ROS_WS=/root/vamos/vamos_ws
RUN mkdir -p $ROS_WS/src

# Clone VAMOS repository (if needed) or mount as volume
# For building the image, we'll clone it; for runtime, mount your local copy
RUN git clone https://github.com/kirillMouraviev/vamos.git /tmp/vamos && \
    cp -r /tmp/vamos/vamos_ws/src/* $ROS_WS/src/ 2>/dev/null || true && \
    cp /tmp/vamos/environment.yml /tmp/ && \
    cp /tmp/vamos/environment_ros.yml /tmp/ && \
    rm -rf /tmp/vamos

# Create the conda environment
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
RUN conda env create -f /tmp/environment_ros.yml && \
    conda clean -afy

# Activate environment in all shells
RUN echo "conda activate vamos" >> ~/.bashrc

# Source ROS and build the workspace
SHELL ["/bin/bash", "-c"]
RUN source /opt/conda/etc/profile.d/conda.sh && \
    conda activate vamos && \
    # Initialize rosdep
    rosdep init && \
    rosdep update && \
    # Install ROS dependencies
    cd $ROS_WS && \
    rosdep install --from-paths src --ignore-src -r -y || true && \
    # Build the catkin workspace
    source /opt/ros/noetic/setup.bash && \
    catkin build -j$(nproc) || true

# Set up environment variables for ROS
RUN echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate vamos" >> ~/.bashrc && \
    echo "source $ROS_WS/devel/setup.bash" >> ~/.bashrc

# Set entrypoint to source environment automatically
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
