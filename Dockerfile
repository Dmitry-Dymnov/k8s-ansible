FROM alpine:3.18

RUN apk --update --no-cache add \
        ca-certificates \
        git \
        openssh-client \
        openssl \
        python3\
        py3-pip \
        py3-cryptography \
        rsync \
        sshpass

RUN apk --update --no-cache add --virtual \
        .build-deps \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base \
        curl

RUN pip3 install --upgrade \
        pip \
        cffi \
 && pip3 install \
        ansible \
        ansible-lint \
 && apk del \
        .build-deps \
 && rm -rf /var/cache/apk/* \
 && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O  \
        /usr/local/bin/yq \
 && chmod +x /usr/local/bin/yq 

RUN mkdir -p /etc/ansible /root/.ssh \
 && echo 'localhost' > /etc/ansible/hosts \
 && echo -e """\
\n\
Host *\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile=/dev/null\n\
""" >> /etc/ssh/ssh_config