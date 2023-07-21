#!/bin/sh
set -o errexit
set -o nounset

# If cgroups v2 are enabled, ensure nesting compatibility.
# NOTE: this may not be necessary anymore in K3s due to
# https://github.com/k3s-io/k3s/pull/4086
#########################################################################################################################################
# DISCLAIMER																																																														#
# Copied from https://github.com/moby/moby/blob/ed89041433a031cafc0a0f19cfe573c31688d377/hack/dind#L28-L37															#
# Permission granted by Akihiro Suda <akihiro.suda.cz@hco.ntt.co.jp> (https://github.com/rancher/k3d/issues/493#issuecomment-827405962)	#
# Moby License Apache 2.0: https://github.com/moby/moby/blob/ed89041433a031cafc0a0f19cfe573c31688d377/LICENSE														#
#########################################################################################################################################
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
	# move the processes from the root group to the /init group,
  # otherwise writing subtree_control fails with EBUSY.
  mkdir -p /sys/fs/cgroup/init
  busybox xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
  # enable controllers
  sed -e 's/ / +/g' -e 's/^/+/' <"/sys/fs/cgroup/cgroup.controllers" >"/sys/fs/cgroup/cgroup.subtree_control"
fi

if [ "${DOCKER_REGISTRY:-x}" != "x" ]; then
  mkdir -p /etc/rancher/k3s
  cat >/etc/rancher/k3s/registries.yaml <<EOF
mirrors:
  docker.io:
    endpoint:
      - "$DOCKER_REGISTRY"
EOF
fi

echo "loading ipip kernel module + deps"
set -x
modprobe ip_tunnel
modprobe tunnel4
insmod /kmods/net/ipv4/ipip.ko

echo "loading netfilter kernel mods for k3s"
insmod /kmods/net/netfilter/xt_mark.ko
insmod /kmods/net/netfilter/xt_statistic.ko
insmod /kmods/net/netfilter/xt_comment.ko

echo "loading netfilter kernel mods for calico"
insmod /kmods/net/netfilter/xt_multiport.ko
insmod /kmods/net/netfilter/nf_conntrack_netlink.ko
insmod /kmods/net/netfilter/xt_bpf.ko
insmod /kmods/net/netfilter/xt_u32.ko


echo "Checking system requirements for k3s" \
  && k3s check-config || true

echo "Checking system requirements for calico" \
  && calicoctl node checksystem || true

set +x
echo "starting k3s agent"
k3s agent \
  --kubelet-arg=volume-plugin-dir=/opt/libexec/kubernetes/kubelet-plugins/volume/exec \
  "$@"
