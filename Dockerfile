FROM public.ecr.aws/lambda/nodejs:16

ARG LAMBDA_TASK_ROOT=/var/task
ARG LAMBDA_RUNTIME_DIR=/var/runtime

# Required for puppeteer to run
RUN yum install -y amazon-linux-extras
RUN amazon-linux-extras install epel -y

# Chromium dependencies
RUN yum install -y \
    GConf2.x86_64 \
    alsa-lib.x86_64 \
    atk.x86_64 \
    cups-libs.x86_64 \
    gtk3.x86_64 \
    ipa-gothic-fonts \
    libXScrnSaver.x86_64 \
    libXcomposite.x86_64 \
    libXcursor.x86_64 \
    libXdamage.x86_64 \
    libXext.x86_64 \
    libXi.x86_64 \
    libXrandr.x86_64 \
    libXtst.x86_64 \
    pango.x86_64 \
    xorg-x11-fonts-100dpi \
    xorg-x11-fonts-75dpi \
    xorg-x11-fonts-Type1 \
    xorg-x11-fonts-cyrillic \
    xorg-x11-fonts-misc \
    xorg-x11-utils

RUN yum update -y nss

# Chromium needs to be installed as a system dependency, not via npm; otherwise there will be an error about missing libatk-1.0
RUN yum install -y chromium git
RUN chromium-browser --version
RUN yum install -y which
RUN which chromium-browser

#install ffmpeg from file ffmpeg-release-amd64-static.tar.xz
COPY ffmpeg ffmpeg
RUN mv ffmpeg /usr/bin/ffmpeg
RUN ffmpeg -version

COPY . ${LAMBDA_TASK_ROOT}

WORKDIR ${LAMBDA_TASK_ROOT}/app

RUN npm ci --omit=dev

CMD [ "app/app.lambdaHandler" ]
#ENTRYPOINT [ "tail", "-f", "/dev/null" ]