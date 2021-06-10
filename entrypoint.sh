#!/bin/bash





tmp_dir="/tmp"
[ -d "/dev/shm" ] && tmp_dir="/dev/shm"
#APRSKEY=""


cmd="/usr/local/bin/pymultimonaprs"


#name=`basename $0`
name="pymultimonaprs"
pid_file="/var/run/$name.pid"
#stdout_log="/var/log/$name.log"
stdout_log="$tmp_dir/$name.log"
#stderr_log="/var/log/$name.err"
stderr_log="$tmp_dir/$name.err"


RTL_BUILD_DIR=~/rtl_build
CONFIG_FILE="/etc/pymultimonaprs.json"
frequency=144.39
default_gain=39
#aprs_gateway="noam.aprs2.net"
aprs_gateway="euro.aprs2.net"
aprs_gateway_port=14580
status_text="RTL-SDR on $(uname -m) $(uname -s) built with http://git.io/v3QXq configuration"

default_ppm="0"
default_device_index="0"
default_latitude="0.000000"
default_longitude="0.000000"
default_table="R"
default_symbol="&"
default_comment="PyMultimonAPRS iGate"







if [ ! -z "$CALLSIGN" ]; then

if [ -z "$APRSKEY" ]; then
APRSKEY=`aprs_keygen.py "$CALLSIGN" | awk '{print $4}'`
fi

if [ -z "$GATEWAY" ]; then
GATEWAY="${aprs_gateway}:${aprs_gateway_port}"
fi

if [ -z "$FREQ" ]; then
FREQ="$frequency"
fi

if [ -z "$PPM" ]; then
PPM="$default_ppm"
fi

if [ -z "$GAIN" ]; then
GAIN="$default_gain"
fi

if [ -z "$DEVICE_INDEX" ]; then
DEVICE_INDEX="$default_device_index"
fi

if [ -z "$LAT" ]; then
LAT="$default_latitude"
fi

if [ -z "$LNG" ]; then
LNG="$default_longitude"
fi

if [ -z "$TABLE" ]; then
TABLE="$default_table"
fi

if [ -z "$SYMBOL" ]; then
SYMBOL="$default_symbol"
fi

if [ -z "$COMMENT" ]; then
COMMENT="$default_comment"
fi

if [ -z "$TEXT" ]; then
TEXT="$status_text"
fi


cp "$CONFIG_FILE" "$tmp_dir/pymultimonaprs.json" && CONFIG_FILE="$tmp_dir/pymultimonaprs.json"


sed -i "s/\"callsign\": [^,]*,/\"callsign\": \"$CALLSIGN\",/g" $CONFIG_FILE
sed -i "s/\"passcode\": [^,]*,/\"passcode\": \"$APRSKEY\",/g" $CONFIG_FILE
sed -i "s/\"gateway\": [^,]*,/\"gateway\": \[\"$GATEWAY\",/g" $CONFIG_FILE
sed -i "s/\"freq\": [^,]*,/\"freq\": $FREQ,/g" $CONFIG_FILE
sed -i "s/\"ppm\": [^,]*,/\"ppm\": $PPM,/g" $CONFIG_FILE
sed -i "s/\"gain\": [^,]*,/\"gain\": $GAIN,/g" $CONFIG_FILE
sed -i "s/\"lat\": [^,]*,/\"lat\": $LAT,/g" $CONFIG_FILE
sed -i "s/\"lng\": [^,]*,/\"lng\": $LON,/g" $CONFIG_FILE
sed -i "s|\"text\": [^,]*,|\"text\": \"$TEXT\",|g" $CONFIG_FILE

sed -i "s/\"device_index\": [^,]*,/\"device_index\": $DEVICE_INDEX,/g" $CONFIG_FILE
sed -i "s|\"table\": [^,]*,|\"table\": \"$TABLE\",|g" $CONFIG_FILE
sed -i "s|\"symbol\": [^,]*,|\"symbol\": \"$SYMBOL\",|g" $CONFIG_FILE
sed -i "s|\"comment\": [^,]*,|\"comment\": \"$COMMENT\",|g" $CONFIG_FILE


#$cmd -c "$CONFIG_FILE" >> "$stdout_log" 2>> "$stderr_log"
$cmd -c "$CONFIG_FILE" > /dev/null 2>&1

if [ -f "$pid_file" ]; then
    rm "$pid_file"
fi


else
	echo >&2 'error: missing required CALLSIGN environment variable'
	echo >&2 '  Did you forget to -e CALLSIGN=... ?'
	exit 1
fi











exit 0









