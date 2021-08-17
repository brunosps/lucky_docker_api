FROM crystallang/crystal:1.1.1-alpine-build as build-image

ENV MUSL_LOCPATH /usr/share/i18n/locales/musl
ENV MUSL_LOCALE_DEPS cmake make musl-dev gcc gettext-dev libintl

RUN apk add --no-cache --update \
  $MUSL_LOCALE_DEPS \
  && wget https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip \
  && unzip musl-locales-master.zip \
  && cd musl-locales-master \
  && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install

WORKDIR /usr/local/
RUN git clone https://github.com/luckyframework/lucky_cli && \
  cd lucky_cli && \
  git checkout v0.28.0 --quiet && \
  shards install

WORKDIR /usr/local/bin/
COPY ./docker-conf/overmind-v2.2.2-linux-arm64 overmind
COPY ./entrypoint.sh entrypoint.sh

WORKDIR /usr/local/lucky_cli
RUN crystal build src/lucky.cr -o /usr/local/bin/lucky

FROM crystallang/crystal:1.1.1-alpine as runtime-image

WORKDIR /opt/app/

RUN apk add --no-cache --update postgresql-client bash tmux vim
COPY --from=build-image /usr/local/bin/lucky /usr/local/bin/lucky
COPY --from=build-image /usr/local/bin/overmind /usr/local/bin/overmind
COPY --from=build-image /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --from=build-image /usr/share/i18n/locales/musl /usr/share/i18n/locales/musl

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENTRYPOINT ["entrypoint.sh"]
EXPOSE 5000

CMD ["lucky", "dev"]