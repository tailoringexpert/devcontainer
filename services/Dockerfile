ARG TAILORINGEXPERT_MAVEN_VERSION=3.9-eclipse-25
FROM ghcr.io/tailoringexpert/maven:${TAILORINGEXPERT_MAVEN_VERSION}

ARG USER=developer
ARG USER_HOME_DIR="/home/$USER"

ARG NODE_VERSION=lts

RUN \
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get update &&  \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends sudo vim less dos2unix nodejs pinentry-curses graphviz git-flow git-lfs && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN \
    useradd -m -s /bin/bash $USER && \
    echo "export GPG_TTY=\$(tty)" >> "$USER_HOME_DIR/.bashrc" && \
    passwd -d $USER && \
    echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER

COPY --chown=$USER:$USER ./devcontainer/home/developer/ $USER_HOME_DIR
    
RUN \
    chmod a+x $USER_HOME_DIR/bin/repos.sh $USER_HOME_DIR/bin/gpgkeys.sh && \
    mkdir -p $USER_HOME_DIR/workspace/.vscode $USER_HOME_DIR/.m2 $USER_HOME_DIR/.gnupg && \
    chown -R $USER:$USER $USER_HOME_DIR/workspace $USER_HOME_DIR/.m2 $USER_HOME_DIR/.gnupg
    
RUN \
    git config --global credential.helper store
    
RUN \
    chmod 0700 $USER_HOME_DIR/.gnupg

ENV PATH="${PATH}:${USER_HOME_DIR}/bin"     

VOLUME \
    $USER_HOME_DIR/workspace \
    $USER_HOME_DIR/.m2 \
    $USER_HOME_DIR/.gnupg
        
USER $USER

