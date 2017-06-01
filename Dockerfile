FROM 250424072945.dkr.ecr.us-east-1.amazonaws.com/base:latest

RUN mkdir /varys
WORKDIR /varys
ADD container_assets/bowerrc /root/.bowerrc
ADD Gemfile /varys/Gemfile
ADD Gemfile.lock /varys/Gemfile.lock
ARG exclude_gems=none
ARG bundle_mode=
RUN gem update bundler && bundle config build.nokogiri --use-system-libraries &&\
  bundle install --without $exclude_gems $bundle_mode --jobs 8
ADD . /varys

# build web assets
RUN cd /varys/public/app && npm install --production &&\
  cd /varys/public/app && npm run bower-install &&\
  (cd /varys/ && npm install)&&\
  (cd /varys/ && npm run gulp-build)

# configure nginx
RUN cp /varys/container_assets/sites-available /etc/nginx/sites-available/default

# Configure log files to go to stdout
RUN ln -sf /dev/stdout /var/log/nginx/access.log &&\
  ln -sf /dev/stderr /var/log/nginx/error.log


CMD ["bundle", "exec", "unicorn_rails", "-c", "config/unicorn.rb"]
