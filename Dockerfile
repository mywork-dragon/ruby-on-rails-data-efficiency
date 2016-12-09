FROM ruby:2.1.10
# To allow for installing of proper node and npm

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -

RUN apt-get update -qq && apt-get install -y \
  autoconf \
  bison \
  build-essential \
  curl \
  git-core \
  htop \
  libc6-dev \
  libcurl3 \
  libcurl3-gnutls \
  libcurl4-openssl-dev \
  libmysqlclient-dev \
  libpq-dev \
  libreadline6 \
  libreadline6-dev \
  libssl-dev \
  libxml2 \
  libxml2-dev \
  libyaml-dev \
  mariadb-client-10.0 \
  nginx \
  nodejs \
  ntp \
  openssl \
  ruby-mysql2 \
  ruby-safe-yaml \
  s3cmd \
  sysstat \
  unzip \
  vim \
  zip \
  zlib1g \
  zlib1g-dev \
  pkg-config

RUN mkdir /varys
WORKDIR /varys
ADD container_assets/bowerrc /root/.bowerrc
RUN gem update bundler
RUN bundle config build.nokogiri --use-system-libraries
ADD Gemfile /varys/Gemfile
ADD Gemfile.lock /varys/Gemfile.lock
ARG exclude_gems=none
RUN bundle install --without $exclude_gems
ADD . /varys

# build web assets
RUN cd /varys/public/app && npm install --production
RUN cd /varys/public/app && npm run bower-install
RUN npm install
RUN npm run gulp-build

# configure nginx
ADD ./container_assets/sites-available /etc/nginx/sites-available/default

# Configure log files to go to stdout
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log
RUN ln -sf /dev/stdout /tmp/sidekiq.log
RUN ln -sf /dev/stdout /tmp/unicorn.out.log \
    && ln -sf /dev/stderr /tmp/unicorn.err.log

CMD ["bundle", "exec", "unicorn_rails", "-c", "config/unicorn.rb"]
