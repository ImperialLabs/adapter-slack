FROM slapi/ruby:latest

MAINTAINER SLAPI Devs

ENV APP_HOME /adapter

RUN mkdir -p $APP_HOME && chmod 777 $APP_HOME

WORKDIR /adapter

COPY supervisord.conf /etc/supervisor.d/supervisord.conf

# Copy app into container
COPY . $APP_HOME

RUN apk update && apk add \
    supervisor &&\
    echo 'gem: --no-document' >> /root/.gemrc &&\
    if [ -f Gemfile.lock ]; then rm -f Gemfile.lock; fi &&\
    gem install bundle &&\
    bundle install &&\
    rm -rf /var/cache/apk/* &&\
    rm -rf /tmp/*

EXPOSE 4700

ENTRYPOINT ["supervisord", "-c", "/etc/supervisor.d/supervisord.conf", "-n"]
