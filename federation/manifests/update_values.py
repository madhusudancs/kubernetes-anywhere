#!/usr/bin/python

# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
from ruamel import yaml


def updateValues(valuesFile, token):
  y = {}
  with open(valuesFile) as f:
    y = yaml.load(f) or {}
    y['apiserverToken'] = '{0}'.format(token)
    y['apiserverKnownTokens'] = '{0},admin,admin'.format(token)

  with open(valuesFile, 'w') as f:
    yaml.dump(y, f, default_flow_style=False)


def main():
  parser = argparse.ArgumentParser(
      description='Update federation API server tokens in values.yaml')
  parser.add_argument(
      'valuesFile', metavar='ValuesFile', type=str, nargs=1,
      help='Values file.')
  parser.add_argument(
      '--token', dest='token',
      help='Federation API server token')

  args = parser.parse_args()

  updateValues(args.valuesFile[0], args.token)


if __name__ == '__main__':
  main()
