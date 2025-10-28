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

RUN apt-get update \
    && apt-get install -y libxmlrpc-epi0 \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN echo "root ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "%sudo ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

RUN mkdir -p -m 755 /etc/apt/keyrings \
    && curl -sS -o /etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# https://gha-cache-server.falcondev.io/getting-started#binary-patch
#RUN sed -i 's/\x41\x00\x43\x00\x54\x00\x49\x00\x4F\x00\x4E\x00\x53\x00\x5F\x00\x52\x00\x45\x00\x53\x00\x55\x00\x4C\x00\x54\x00\x53\x00\x5F\x00\x55\x00\x52\x00\x4C\x00/\x41\x00\x43\x00\x54\x00\x49\x00\x4F\x00\x4E\x00\x53\x00\x5F\x00\x52\x00\x45\x00\x53\x00\x55\x00\x4C\x00\x54\x00\x53\x00\x5F\x00\x4F\x00\x52\x00\x4C\x00/g' /home/runner/bin/Runner.Worker.dll

USER runner

RUN docker-credential-gcr configure-docker --include-artifact-registry
