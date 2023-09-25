FROM ruby:2.7 as jekyll-serve

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN gem update --system && gem install bundler && gem install sass-embedded -v 1.58.0 && gem install jekyll

EXPOSE 4000

WORKDIR /site

CMD [ "bundle", "exec", "jekyll", "serve", "--force_polling", "-H", "0.0.0.0", "-P", "4000" ]
