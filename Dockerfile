FROM ubuntu:26.04

RUN apt update && apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        bash \
        python3 \
        python3-venv \
        python3-pip \
        lv \
	tmux \
        vim \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

USER ubuntu
ENV HOME=/home/ubuntu
ENV PATH="${HOME}/.local/bin:${PATH}"
WORKDIR /workspace

RUN curl -fsSL https://claude.ai/install.sh | bash

CMD ["bash"]
