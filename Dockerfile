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
	fonts-noto-cjk \
	git \
	jq \
	less \
	lv \
	mmdebstrap \
	nodejs \
	npm \
	openssh-client \
	poppler-utils \
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

# bind mount した ./workspace を母艦側ユーザと同じ uid/gid で読み書きできるように、
# ubuntu ユーザの uid/gid をビルド時に母艦側へ合わせる(既定は 1000:1000)。
ARG HOST_UID=1000
ARG HOST_GID=1000
RUN if [ "$(id -g ubuntu)" != "${HOST_GID}" ]; then groupmod -g "${HOST_GID}" ubuntu; fi \
    && if [ "$(id -u ubuntu)" != "${HOST_UID}" ]; then usermod -u "${HOST_UID}" -g "${HOST_GID}" ubuntu; fi \
    && chown -R "${HOST_UID}:${HOST_GID}" /home/ubuntu

RUN mkdir -p /var/cache/rootfs && chown ubuntu:ubuntu /var/cache/rootfs
ENV ROOTFS_DIR=/var/cache/rootfs
COPY --chmod=755 rootfs-run /usr/local/bin/rootfs-run

RUN pip3 install --break-system-packages --root-user-action=ignore uv wheel setuptools

USER ubuntu
ENV HOME=/home/ubuntu
ENV PATH="${HOME}/.local/bin:${PATH}"
ENV LANG=C.UTF-8
ENV ASTRO_TELEMETRY_DISABLED=1
ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV NPM_CONFIG_FUND=false

WORKDIR /workspace

RUN curl -fsSL https://claude.ai/install.sh | bash

CMD ["bash"]
