import json
import os
import sys

import requests
from kubernetes import client, config

image_name = sys.argv[1]
update = {}
namespace = None
config.incluster_config.load_incluster_config()

with open("/var/run/secrets/kubernetes.io/serviceaccount/namespace") as namespace_file:
    namespace = namespace_file.read()


api = client.ApiClient()
core = client.CoreV1Api(api)
custom = client.CustomObjectsApi(api)
latest_build = custom.get_namespaced_custom_object(
    'image.openshift.io', 'v1', namespace, 'imagestreamtags', f"{image_name}:latest")

plugins = [(key.split('.')[3], value) for key, value in latest_build.get('image').get('dockerImageMetadata').get(
    'ContainerConfig').get('Labels').items() if key.startswith('org.wordpress.plugin')]
themes = [(key.split('.')[3], value) for key, value in latest_build.get('image').get('dockerImageMetadata').get(
    'ContainerConfig').get('Labels').items() if key.startswith('org.wordpress.theme')]

for plugin in plugins:
    latest = requests.get(f"https://api.wordpress.org/plugins/info/1.0/{plugin[0]}.json").json().get('version')
    if latest != plugin[1]:
        update[f"${plugin[0].upper()}_VERSION"] = latest


if update:
    core.patch_namespaced_config_map(
        f"${image_name}-config",
        namespace,
        f'{{"data":{{${json.dumps(update)}}}}}')

    requests.post(
        f"https://api.homelab.csfreak.com:6443/apis/build.openshift.io/v1/namespaces/{namespace}/buildconfigs/{image_name}/webhooks/{os.environ.get('WebHookSecretKey')}/generic")
