FROM node:8

LABEL Description="Node LTS with yarn and OpenJDK 8"

# ——————————
# Installs i386 architecture required for running 32 bit Android tools
# and base software packages
# ——————————
RUN dpkg --add-architecture i386 && \
    echo "deb http://http.debian.net/debian jessie-backports main" | tee --append /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install -t jessie-backports openjdk-8-jdk && \
    apt-get install -y \
    libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 \
    unzip && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN cd /opt && \
    wget --output-document=android-sdk.zip --quiet https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
    unzip android-sdk.zip -d android-sdk-linux && \
    rm android-sdk.zip && \
    mkdir -p "$ANDROID_HOME/licenses" && \
    echo -e "\n2f0d1357ae7b730389d07594f0e9b502cc6fe51f" > "$ANDROID_HOME/licenses/android-googletv-license" && \
    echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license" && \
    echo -e "\nd23d63a1f23e25e2c7a316e29eb60396e7924281" > "$ANDROID_HOME/licenses/android-sdk-preview-license" && \
    echo -e "\n33b6a2b64607f11b759f320ef9dff4ae5c47d97a" > "$ANDROID_HOME/licenses/google-gdk-license" && \
    echo -e "\ne0c19d95f989716a8960e651953886c9fc1f8c0a" > "$ANDROID_HOME/licenses/mips-android-sysimage-license" && \
    sdkmanager --verbose tools platform-tools \
        "platforms;android-23" "platforms;android-26" \
        "build-tools;23.0.1" "build-tools;26.0.1" \
        "extras;android;m2repository" "extras;google;m2repository" \
        #"extras;google;google_play_services" \
        "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

# ——————————
# Install udev rules for most android devices
# ——————————
RUN mkdir -p /etc/udev/rules.d/ && cd /etc/udev/rules.d/ && \
    wget https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
