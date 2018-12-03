
FROM sudachen/pyscript:latest

USER $NB_USER

RUN pip install -U --no-cache-dir \
        flask \
        flask-sqlalchemy \
        flask-oauthlib \
        flask-admin 

USER root

ENV UNICORNS=3 \
    HOSTED_WEBAPP="IN_THE_CLOUDS"
    
COPY app /app
COPY nginx.conf /etc/nginx/
COPY circus.ini /etc/

RUN chown -R $NB_UID:$NB_GID /app
