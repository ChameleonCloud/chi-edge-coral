#!/bin/sh

case "$1" in
  aarch64)
    k3s_bin="k3s-arm64"
    calicoctl_bin="calicoctl-linux-arm64"
    ;;
  armv7hf)
    k3s_bin="k3s-armhf"
    calicoctl_bin="calicoctl-linux-armv7"
    ;;
  amd64)
    k3s_bin="k3s"
    calicoctl_bin="calicoctl-linux-amd64"
    ;;
  *)
    echo "unknown arch $1, cannot install k3s"
    exit 1
    ;;
esac

curl -sSfL -o /usr/local/bin/k3s \
  https://github.com/k3s-io/k3s/releases/download/"${K3S_VERSION}"/"${k3s_bin}"
chmod +x /usr/local/bin/k3s

curl -sSfL -o /usr/local/bin/calicoctl \
  "https://github.com/projectcalico/calico/releases/latest/download/${calicoctl_bin}"
chmod +x /usr/local/bin/calicoctl
