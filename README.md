# APRS-iGate_Docker
APRS-iGate_Docker

## Start:

1. Install docker-ce:
```
[tcjj3@debian]$ sudo apt install -y curl
[tcjj3@debian]$ curl -fsSL get.docker.com -o get-docker.sh
[tcjj3@debian]$ sudo sh get-docker.sh
[tcjj3@debian]$ sudo groupadd docker
[tcjj3@debian]$ sudo usermod -aG docker $USER
[tcjj3@debian]$ sudo systemctl enable docker && sudo systemctl start docker
```

2. Run APRS-iGate_Docker:
```
sudo docker run -d -i -t \
 --restart always \
 --name=APRS-iGate \
 --device /dev/bus/usb \
 -e CALLSIGN="XXXXXX" \
 -e SSID="1" \
 -e GATEWAY="euro.aprs2.net:14580" \
 -e PREFERRED_PROTOCOL="any" \
 -e APPEND_CALLSIGN="true" \
 -e SOURCE="rtl" \
 -e FREQ="144.39" \
 -e PPM="0" \
 -e GAIN="39" \
 -e OFFSET_TUNING="false" \
 -e DEVICE_INDEX="0" \
 -e DEVICE="default" \
 -e LAT="XX.XXXXXX" \
 -e LNG="XXX.XXXXXX" \
 -e TABLE="R" \
 -e SYMBOL="\\&" \
 -e COMMENT="PyMultimonAPRS iGate" \
 -e TEXT="RTL-SDR on $(uname -m) $(uname -s) using PyMultimonAPRS iGate" \
 -e SEND_EVERY="300" \
 -e AMBIGUITY="0" \
 tcjj3/aprs-igate_docker:latest
```

