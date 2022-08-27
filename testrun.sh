#!/bin/bash

set -x;

./archiso/scripts/run_archiso.sh -i out/$(ls out/);
