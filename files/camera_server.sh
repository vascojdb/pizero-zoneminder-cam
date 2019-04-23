#!/bin/bash

control_c() {
  pkill camera_server.sh
  echo ""
  echo "Aborted by the user. Exiting..."
  exit
}

trap control_c SIGINT

while true
do
  echo "Welcome to Raspberry Pi Camera server!"
  
  echo "Reading configuration file..."
  source /home/pi/scripts/camera_server.conf

  # Adding video settings parameters:
  PARAMS="--nopreview --timeout 0 -w ${WIDTH} -h ${HEIGHT} -b ${BITRATE} -fps ${FRAMERATE} "

  # Adding optional image parameters:
  if [ ! -z "${SHARPNESS}" ]; then PARAMS="${PARAMS} -sh ${SHARPNESS} "; fi
  if [ ! -z "${CONTRAST}" ]; then PARAMS="${PARAMS} -co ${CONTRAST} "; fi
  if [ ! -z "${BRIGHTNESS}" ]; then PARAMS="${PARAMS} -br ${BRIGHTNESS} "; fi
  if [ ! -z "${SATURATION}" ]; then PARAMS="${PARAMS} -sa ${SATURATION} "; fi
  if [ ! -z "${ISO}" ]; then PARAMS="${PARAMS} -ISO ${ISO} "; fi
  if [ ! -z "${EV}" ]; then PARAMS="${PARAMS} -ev ${EV} "; fi

  if [ ! -z "${EXPOSURE}" ]; then PARAMS="${PARAMS} -ex ${EXPOSURE} "; fi
  if [ ! -z "${FLICKER_AVOID}" ]; then PARAMS="${PARAMS} -fli ${FLICKER_AVOID} "; fi
  if [ ! -z "${AWB}" ]; then PARAMS="${PARAMS} -awb ${AWB} "; fi
  if [ ! -z "${IMAGE_EFFECT}" ]; then PARAMS="${PARAMS} -ifx ${IMAGE_EFFECT} "; fi
  if [ ! -z "${METERING}" ]; then PARAMS="${PARAMS} -mm ${METERING} "; fi
  if [ ! -z "${ROTATION}" ]; then PARAMS="${PARAMS} -rot ${ROTATION} "; fi

  if [ ! -z "${HORIZONTAL_FLIP}" ]; then PARAMS="${PARAMS} -hf "; fi
  if [ ! -z "${VERTICAL_FLIP}" ]; then PARAMS="${PARAMS} -vf "; fi

  if [ ! -z "${DRC}" ]; then PARAMS="${PARAMS} -drc ${DRC} "; fi
  if [ ! -z "${ANNOTATE}" ]; then PARAMS="${PARAMS} -a ${ANNOTATE} "; fi

  # Adding additional parameters:
  PARAMS="${PARAMS} -cd MJPEG -l -o tcp://0.0.0.0:${TCP_PORT}"

  echo "Running: raspivid ${PARAMS}"

  #raspivid ${PARAMS}

  echo "Raspivid exited. Waiting 5 seconds to start again..."
  sleep 5
  echo ""
done

