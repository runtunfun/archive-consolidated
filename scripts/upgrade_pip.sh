#!/bin/bash

PYTHON=$(which python)
echo ${PYTHON}
${PYTHON} -m pip install --upgrade pip
for PIP in `pip list --outdated | egrep -v '^Package|^----' | cut -d " " -f 1`
do
pip install --upgrade ${PIP}
done
