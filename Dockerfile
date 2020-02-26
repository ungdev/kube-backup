FROM alpine:3.7

RUN apk update && \
  apk add --update \
    bash \
    easy-rsa \
    git \
    openssh-client \
    curl \
    ca-certificates \
    jq \
    python \
    py-yaml \
    py2-pip \
    libstdc++ \
    gpgme \
    libressl-dev \
    make \
    g++ \
    && \
  git clone https://github.com/AGWA/git-crypt.git && \
  make --directory git-crypt && \
  make --directory git-crypt install && \
  rm -rf git-crypt && \
  apk del libressl-dev make g++ && \
  rm -rf /var/cache/apk/* && \
  pip install ijson awscli && \
  adduser -D -u 1000 -s /bin/ash backup && \
  chown -R root:root /backup && \
  chmod -R g=u /backup

ENV KUBECTL_VERSION 1.12.0
ENV KUBECTL_SHA256 ba0f8d5776d84ffef5ce5d5c31f8d892e0c13d073948d5bafbb5341ad68ef463
ENV KUBECTL_URI https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
ENV HOME /backup

RUN curl -SL ${KUBECTL_URI} -o kubectl && chmod +x kubectl

RUN echo "${KUBECTL_SHA256}  kubectl" | sha256sum -c - || exit 10
ENV PATH="/:${PATH}"

COPY entrypoint.sh /
WORKDIR /backup

USER 1000

ENTRYPOINT ["/entrypoint.sh"]
