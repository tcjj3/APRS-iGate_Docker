FROM debian:buster-slim

LABEL maintainer "Chaojun Tan <https://github.com/tcjj3>"

ADD entrypoint.sh /opt/entrypoint.sh

RUN export DIR_TMP="$(mktemp -d)" \
  && cd ${DIR_TMP} \
  && chmod +x /opt/*.sh \
  && sed -i "s/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
  && sed -i "s/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list \
  && apt-get update \
  || echo "continue..." \
  && echo "Install dependencies" \
  && apt-get install --no-install-recommends -y procps psmisc net-tools iproute2 ca-certificates git build-essential cmake libusb-1.0-0-dev sox libtool autoconf automake libfftw3-dev qt4-qmake libpulse-dev libx11-dev python-pkg-resources bc checkinstall \
  || apt-get install --no-install-recommends -y procps psmisc net-tools iproute2 ca-certificates git build-essential cmake libusb-1.0-0-dev sox libtool autoconf automake libfftw3-dev qt4-qmake libpulse-dev libx11-dev python-pkg-resources bc \
  && echo "Install dependencies done." \
  && RTL_BUILD_DIR=~/rtl_build \
  && if [ "$(dpkg --print-architecture)" = "armhf" ]; then \
        ARCH="arm"; \
     else \
        ARCH=$(dpkg --print-architecture); \
     fi \
  && echo "Configure blacklist" \
  && ([ ! -d /etc/modprobe.d ] && mkdir -p /etc/modprobe.d) || echo "continue..." \
  && BLACKLIST_PATH=/etc/modprobe.d/blacklist.conf \
  && if [ -a /etc/modprobe.d/raspi-blacklist.conf ]; then \
        BLACKLIST_PATH=/etc/modprobe.d/raspi-blacklist.conf; \
     else \
        BLACKLIST_PATH=/etc/modprobe.d/blacklist.conf; \
     fi \
  && echo "blacklist dvb_usb_rtl28xxu" >> $BLACKLIST_PATH || echo "continue..." \
  && echo "blacklist rtl_2832" >> $BLACKLIST_PATH || echo "continue..." \
  && echo "blacklist rtl_2830" >> $BLACKLIST_PATH || echo "continue..." \
  && echo "Configure blacklist done." \
  && echo "Create RTL-SDR directory" \
  && mkdir $RTL_BUILD_DIR \
  && echo "Create RTL-SDR directory done." \
  && echo "Get APRS-iGate setup scripts" \
  && cd $RTL_BUILD_DIR \
  && git clone https://github.com/mmiller7/aprs-igate-rtl-sdr-setup \
  && echo "Get APRS-iGate setup scripts done." \
  && echo "Build new driver" \
  && cd $RTL_BUILD_DIR \
  && git clone git://git.osmocom.org/rtl-sdr.git \
  && cd rtl-sdr \
  && mkdir build \
  && cd build \
  && cmake .. -DINSTALL_UDEV_RULES=ON \
  && make \
  && version=`date '+%Y%m%d'` || echo "continue..." \
  && checkinstall -D --pkgname rtl-sdr --pkggroup rtl-sdr --provides rtl-sdr --pkgversion $version -y && (dpkg -i rtl-sdr_*.deb) || (make install) \
  && ldconfig \
  && echo "Build new driver done." \
  && echo "Install Kalibrate-RTL" \
  && cd $RTL_BUILD_DIR \
  && git clone https://github.com/asdil12/kalibrate-rtl.git \
  && cd kalibrate-rtl \
  && if [ "$ARCH" = "arm" ]; then \
        git checkout arm_memory; \
     fi \
  && ./bootstrap \
  && ./configure \
  && make \
  && version=`src/kal -h | head -1 | awk '{ print $2 }' | sed 's/,//g;s/^v//g'` || echo "continue..." \
  && checkinstall -D --pkgname kalibrate-sdr --pkggroup kalibrate-sdr --provides kal --pkgversion $version -y && (dpkg -i kalibrate-sdr_*.deb) || (make install) \
  && echo "Install Kalibrate-RTL done." \
  && echo "Install multimonNG decoder" \
  && cd $RTL_BUILD_DIR \
  && git clone https://github.com/EliasOenal/multimonNG.git \
  && cd multimonNG \
  && mkdir build \
  && cd build \
  && qmake-qt4 ../multimon-ng.pro || qmake ../multimon-ng.pro \
  && make \
  && version=`./multimon-ng -h 2>&1 | head -1 | awk '{ print $2 }'` || echo "continue..." \
  && checkinstall -D --pkgname multimon-ng --pkggroup multimon-ng --provides multimon-ng --pkgversion $version -y && (dpkg -i multimon-ng_*.deb) || (make install) \
  && echo "Install multimonNG decoder done." \
  && echo "Install APRS iGate software" \
  && cd $RTL_BUILD_DIR \
  && git clone https://github.com/asdil12/pymultimonaprs.git \
  && cd pymultimonaprs \
  && python setup.py build \
  && python setup.py install \
  && cp keygen.py /usr/local/bin/keygen.py \
  && cp keygen.py /usr/local/bin/aprs_keygen.py \
  && echo "Install APRS iGate software done." \
  && echo "Install init.d script template" \
  && cd $RTL_BUILD_DIR \
  && git clone https://github.com/fhd/init-script-template.git \
  && cd init-script-template \
  && mkdir -p $RTL_BUILD_DIR/init.d \
  && cp template $RTL_BUILD_DIR/init.d/pymultimonaprs \
  && cd $RTL_BUILD_DIR/init.d \
  && sed -i 's|cmd=""|cmd="/usr/local/bin/pymultimonaprs"|g' pymultimonaprs \
  && sed -i 's/user=""/user="aprs"/g' pymultimonaprs \
  && sed -i 's/# Provides:/# Provides: pymultimonaprs/g' pymultimonaprs \
  && sed -i 's/# Description:       Enable service provided by daemon./# Description:       Starts pymultimonaprs APRS iGate daemon/g' pymultimonaprs \
  && cp pymultimonaprs /etc/init.d/pymultimonaprs_bak \
  && cp pymultimonaprs /etc/init.d/ \
  && sed -i "s/sudo -u \"\$user\" //gi; s/sudo //gi; " /etc/init.d/pymultimonaprs \
  && useradd -r -s /sbin/nologin -M aprs || echo "continue..." \
  && echo "Install init.d script template done." \
  && rm -rf ${DIR_TMP} \
  && echo "Docker build complete! Enjoy!"











ENTRYPOINT ["bash", "-c", "/opt/entrypoint.sh"]











