
namespace=$1
secretName=$2

if [ -z "${namespace}" ]; then
    echo "usage:  download_keys <namespace> <secretName>"
    exit 1
fi


oc get secret "${secretName}" -n "${namespace}" -o jsonpath={.data."public\.gpg"} | base64 --decode > ./public.gpg
oc get secret "${secretName}" -n "${namespace}" -o jsonpath={.data."private\.gpg"} | base64 --decode > ./private.gpg

