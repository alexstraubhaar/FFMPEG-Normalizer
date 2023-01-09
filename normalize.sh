#!/bin/bash

echo FFMPEG Normalizer Script
read -p "Input filename: " input_filename
read -p "Output filename: " output_filename
read -p "Resolution (NxN): " resolution
read -p "Aspect ratio (N:N or N.N): " aspect
read -p "FPS: " fps
read -p "Subtitles ? (yes/no): " yn

specify_stream=""

ffmpeg_cmd=(./ffmpeg -probesize 50M -analyzeduration 100M -i $input_filename \
		-c:a pcm_s24le -async 1 -c:v prores -r $fps -s $resolution -aspect $aspect \
		-pix_fmt yuv422p10le -coder ac -trellis 0 -subq 6 -me_range 16 \
		-b_strategy 1 -sc_threshold 40 -keyint_min 24 -g 48 -qmin 3 -qmax 51 \
		-metadata creation_time=now $specify_stream \
		-sn -y $output_filename)

case $yn in
	yes ) read -p "Stream number (0-9): " stream;
		specify_stream=(-filter_complex "[0:v][0:s:$stream]overlay[out]" -map "[out]" -map 0:a:0);
		echo $(ffmpeg_cmd);;
	no ) echo $(ffmpeg_cmd);;
	* ) echo Invalid arguments;
		exit 1;;

esac
