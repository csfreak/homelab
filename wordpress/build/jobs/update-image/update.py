import json
import os
import sys

import requests
from kubernetes import client, config

image_name = sys.argv[1]
update = {}
namespace = None
conf = config.incluster_config.load_incluster_config()
conf.debug = True

with open("/var/run/secrets/kubernetes.io/serviceaccount/namespace") as namespace_file:
    namespace = namespace_file.read()


latest_build_labels = client.CustomObjectsApi().get_namespaced_custom_object(
    'image.openshift.io', 'v1', namespace, 'imagestreamtags', f"{image_name}:latest").get(
    'image').get('dockerImageMetadata').get('ContainerConfig').get('Labels')

plugins = [(key.split('.')[3], value)
           for key, value in latest_build_labels.items() if key.startswith('org.wordpress.plugin')]
themes = [(key.split('.')[3], value)
          for key, value in latest_build_labels.items() if key.startswith('org.wordpress.theme')]

for plugin in plugins:
    latest = requests.get(f"https://api.wordpress.org/plugins/info/1.0/{plugin[0]}.json").json().get('version')
    if latest != plugin[1]:
        update[f"{plugin[0].upper()}_VERSION"] = latest

for theme in themes:
    latest = requests.get("https://api.wordpress.org/themes/info/1.1/", params={
        'action': 'theme_information',
        'request[slug]': theme[0]
    }).json().get('version')
    if latest != theme[1]:
        update[f"{theme[0].upper()}_VERSION"] = latest

if update:
    client.CoreV1Api().patch_namespaced_config_map(
        f"{image_name}-build-config",
        namespace,
        {"data": update})
    secret = os.environ.get('WebHookSecretKey').strip("\n")
    requests.post(
        f"https://api.homelab.csfreak.com:6443/apis/build.openshift.io/v1/namespaces/{namespace}/buildconfigs/{image_name}/webhooks/{secret}/generic",
        verify=False)
