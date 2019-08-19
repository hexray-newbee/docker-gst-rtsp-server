ARG UBUNTU_VERSION=19.10

FROM ubuntu:$UBUNTU_VERSION as build

ARG UBUNTU_VERSION
ARG GSTREAMER_VERSION=1.16
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y ca-certificates

COPY $UBUNTU_VERSION-sources.list /etc/apt/sources.list

RUN apt-get update && \
  apt-get install -y \
  git \
  python3-pip \
  ninja-build

# Intall pip and meson
RUN pip3 install -i https://mirrors.aliyun.com/pypi/simple pip -U
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple
RUN pip3 install meson

# Install gstreamer
# Reference https://gstreamer.freedesktop.org/documentation/installing/on-linux.html#install-gstreamer-on-ubuntu-or-debian
RUN apt-get update && \
  apt-get install -y \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  libgstreamer-plugins-good1.0-dev

# gst-rtsp-server
RUN git clone https://gitlab.freedesktop.org/gstreamer/gst-rtsp-server.git -b $GSTREAMER_VERSION --depth=1
RUN cd gst-rtsp-server && meson build -Dtests=disabled && ninja -C build

FROM dyhexl/gst-launch:v1.16 as runtime

COPY --from=build /gst-rtsp-server/build /gst-rtsp-server/build

EXPOSE 8554
WORKDIR /gst-rtsp-server/build/examples/
CMD ./test-launch --help
