FROM sudachen/webapp:latest

MAINTAINER Alexey Sudachen <alexey.sudachen@vacasa.com>

ENV HOSTED_WEBAPP "IN_THE_CLOUDS"

USER root
COPY rqs/requirements*.txt /tmp

RUN mkdir -p $HOME/.ssh \
    && chmod -R og-rxw $HOME/.ssh \
    && echo "Host *" > $HOME/.ssh/config \
    && echo "StrictHostKeyChecking no" >> $HOME/.ssh/config \
    && chown -R $NB_UID:$NB_GID $HOME/.ssh  \
    && chmod +r /tmp/requirements*.txt 
    
USER jupyter

RUN if [ -f /tmp/requirements-conda.txt ]; then \
      conda install -y --file /tmp/requirements-conda.txt && conda clean -tipsy; \  
    fi 
RUN if [ -f /tmp/requirements.txt ]; then \
      /opt/conda/bin/pip install --no-cache-dir -r "/tmp/requirements.txt"; \
    fi 

USER root
WORKDIR /app
COPY app /app
RUN chown -R $NB_UID:$NB_GID /app \
    && chmod -R -w /app/*

