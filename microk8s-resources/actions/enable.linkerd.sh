#!/usr/bin/env bash

set -e

source $SNAP/actions/common/utils.sh
CA_CERT=/snap/core/current/etc/ssl/certs/ca-certificates.crt

read -ra ARGUMENTS <<< "$1"
argz=("${ARGUMENTS[@]/#/--}")

# check if linkerd cli is already in the system.  Download if it doesn't exist.
if [ ! -f "${SNAP_DATA}/bin/linkerd" ]; then
  LINKERD_VERSION="${LINKERD_VERSION:-v2.6.0}"
  echo "Fetching Linkerd2 version $LINKERD_VERSION."
  mkdir -p "$SNAP_DATA/bin"
  LINKERD_VERSION=$(echo $LINKERD_VERSION | sed 's/v//g')
  echo "$LINKERD_VERSION"
  "${SNAP}/usr/bin/curl" --cacert $CA_CERT -L https://github.com/linkerd/linkerd2/releases/download/stable-${LINKERD_VERSION}/linkerd2-cli-stable-${LINKERD_VERSION}-linux -o "$SNAP_DATA/bin/linkerd"
  chmod uo+x "$SNAP_DATA/bin/linkerd"
fi

echo "Enabling Linkerd2"
<<<<<<< d2713cf4c8e0e2e01c4e7b1cecf835993f4d86d6
refresh_opt_in_config "requestheader-allowed-names" "127.0.0.1" kube-apiserver
sudo systemctl restart snap.${SNAP_NAME}.daemon-apiserver
=======
# temporary fix while we wait for linkerd to support v1.16
refresh_opt_in_config "runtime-config" "api/all=true" kube-apiserver
echo "Restarting the API server."
snapctl restart ${SNAP_NAME}.daemon-apiserver
>>>>>>> Remove sudo
sleep 5

# enable dns service
KUBECTL="$SNAP/kubectl --kubeconfig=${SNAP_DATA}/credentials/client.config"
"$SNAP/microk8s-enable.wrapper" dns
# Allow some time for the apiserver to start
sleep 5
${SNAP}/microk8s-status.wrapper --wait-ready --timeout 30 >/dev/null


"$SNAP_DATA/bin/linkerd" "--kubeconfig=$SNAP_DATA/credentials/client.config" install "${argz[@]}" | $KUBECTL apply -f -
echo "Linkerd is starting"
