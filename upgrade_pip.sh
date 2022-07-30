#!/bin/bash

for i in `pip list --outdated | egrep -v '^Package|^----' | cut -d " " -f 1`
do
pip install --upgrade ${i}
done
