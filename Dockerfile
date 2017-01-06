FROM ruby:2.3.1

RUN mkdir /gem
WORKDIR /gem

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

RUN bundle install

RUN mkdir /workdir
WORKDIR /workdir

ENTRYPOINT ["bundle", "exec", "bin/fence"]
