#!/bin/bash

cd /root/vamos/vamos_ws/src/navigate
python setup.py install

cd ../trajectory_prediction
python setup.py install

cd ../trajectory_projection
python setup.py install

cd ../vamos
python setup.py install