FROM ghcr.io/actions/actions-runner:2.329.0

ARG TARGETPLATFORM

USER root

ENV CRED_HELPER_VERSION=2.1.30
RUN export WANTED_PLATFORM=$(echo ${TARGETPLATFORM} | sed 's#/#_#') \
    && curl -f -sS -L -o docker-credential-gcr.tar.gz "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${CRED_HELPER_VERSION}/docker-credential-gcr_${WANTED_PLATFORM}-${CRED_HELPER_VERSION}.tar.gz" \
    && tar -xzf docker-credential-gcr.tar.gz docker-credential-gcr \
    && chmod +x docker-credential-gcr \
    && mv docker-credential-gcr /usr/bin/ \
    && rm -f docker-credential-gcr.tar.gz \
    && docker-credential-gcr configure-docker --include-artifact-registry

RUN echo "root ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

USER runner

RUN docker-credential-gcr configure-docker --include-artifact-registry
