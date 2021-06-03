FROM alpine:3.12.1 as base

ADD https://apk.cloudposse.com/ops@cloudposse.com.rsa.pub /etc/apk/keys/
RUN echo "@cloudposse https://apk.cloudposse.com/3.11/vendor" >> /etc/apk/repositories

RUN apk add -u \
				yq@cloudposse==4.6.3-r0 \
				go-jsonnet@cloudposse==0.17.0-r0 \
				helm3@cloudposse=3.5.4-r0



ENV APP_WORKDIR /app


# Build the CLI
COPY ./ ${APP_WORKDIR}

RUN chmod 755 ${APP_WORKDIR}/entrypoint.sh

ENTRYPOINT ["${APP_WORKDIR}/entrypoint.sh"]

# install git
RUN apk update \
    apk upgrade \
    apk install git





FROM base as test

RUN apk --no-cache add coreutils ncurses curl bats

ENV LIBS_BATS_MOCK_VERSION="1.3.0" \
    LIBS_BATS_SUPPORT_VERSION="0.3.0" \
    LIBS_BATS_ASSERT_VERSION="0.3.0" \
    LIB_BATS_FILE_VERSION="0.2.0"



# Install bats-support
RUN mkdir -p /usr/local/lib/bats/bats-support \
    && curl -sSL https://github.com/ztombol/bats-support/archive/v${LIBS_BATS_SUPPORT_VERSION}.tar.gz -o /tmp/bats-support.tgz \
    && tar -zxf /tmp/bats-support.tgz -C /usr/local/lib/bats/bats-support --strip 1 \
    && printf 'source "%s"\n' "/usr/local/lib/bats/bats-support/load.bash" >> /usr/local/lib/bats/load.bash \
    && rm -rf /tmp/bats-support.tgz

# Install bats-assert
RUN mkdir -p /usr/local/lib/bats/bats-assert \
    && curl -sSL https://github.com/ztombol/bats-assert/archive/v${LIBS_BATS_ASSERT_VERSION}.tar.gz -o /tmp/bats-assert.tgz \
    && tar -zxf /tmp/bats-assert.tgz -C /usr/local/lib/bats/bats-assert --strip 1 \
    && printf 'source "%s"\n' "/usr/local/lib/bats/bats-assert/load.bash" >> /usr/local/lib/bats/load.bash \
    && rm -rf /tmp/bats-assert.tgz

# Install lox's fork of bats-mock
RUN mkdir -p /usr/local/lib/bats/bats-mock \
    && curl -sSL https://github.com/lox/bats-mock/archive/v${LIBS_BATS_MOCK_VERSION}.tar.gz -o /tmp/bats-mock.tgz \
    && tar -zxf /tmp/bats-mock.tgz -C /usr/local/lib/bats/bats-mock --strip 1 \
    && printf 'source "%s"\n' "/usr/local/lib/bats/bats-mock/stub.bash" >> /usr/local/lib/bats/load.bash \
    && rm -rf /tmp/bats-mock.tgz

# Install bats-file
RUN mkdir -p /usr/local/lib/bats/bats-file \
    && curl -sSL https://github.com/ztombol/bats-file/archive/v${LIB_BATS_FILE_VERSION}.tar.gz -o /tmp/bats-file.tgz \
    && tar -zxf /tmp/bats-file.tgz -C /usr/local/lib/bats/bats-file --strip 1 \
    && printf 'source "%s"\n' "/usr/local/lib/bats/bats-file/load.bash" >> /usr/local/lib/bats/load.bash \
    && rm -rf /tmp/bats-file.tgz

# Expose BATS_PATH so people can easily use load.bash
ENV BATS_PATH=/usr/local/lib/bats

WORKDIR ${APP_WORKDIR}

ENTRYPOINT ["bats"]
CMD ["tests/"]



FROM base as run

LABEL maintainer="Goruha <goruha@gmail.com>"

LABEL "com.github.actions.name"="ArgoCD Deploy"
LABEL "com.github.actions.description"="ArgoCD Deploy"
LABEL "com.github.actions.icon"="activity"
LABEL "com.github.actions.color"="blue"
