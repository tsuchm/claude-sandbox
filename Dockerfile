FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update \
    && apt dist-upgrade -y \
    && apt install -y --no-install-recommends \
	bash \
	build-essential \
	ca-certificates \
	curl \
	debian-archive-keyring \
	file \
	git \
	jq \
	less \
	lv \
	mmdebstrap \
	openssh-client \
	procps \
	proot \
	python3 \
	python3-pip \
	python3-venv \
	ripgrep \
	rsync \
	skopeo \
	tmux \
	umoci \
	unzip \
	vim \
	wget \
	xz-utils \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/cache/rootfs && chown ubuntu:ubuntu /var/cache/rootfs
ENV ROOTFS_DIR=/var/cache/rootfs
COPY --chmod=755 rootfs-run /usr/local/bin/rootfs-run

RUN pip3 install --break-system-packages --root-user-action=ignore uv wheel setuptools

USER ubuntu
ENV HOME=/home/ubuntu
ENV PATH="${HOME}/.local/bin:${PATH}"
ENV LANG=C.UTF-8
WORKDIR /workspace

RUN curl -fsSL https://claude.ai/install.sh | bash

CMD ["bash"]
