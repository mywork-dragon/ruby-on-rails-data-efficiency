FROM 250424072945.dkr.ecr.us-east-1.amazonaws.com/base:upgraded_npm_node

RUN mkdir /varys
WORKDIR /varys

# install gems
COPY Gemfile /varys/Gemfile
COPY Gemfile.lock /varys/Gemfile.lock
ARG exclude_gems=none
ARG bundle_mode=
RUN bundle config build.nokogiri --use-system-libraries &&\
  bundle install --without $exclude_gems $bundle_mode --jobs 8

# install frontend dependencies
RUN mkdir -p /tmp/frontend
COPY frontend/package.json /tmp/frontend/package.json
RUN cd /tmp/frontend && yarn install --frozen-lockfile
COPY frontend /tmp/frontend
RUN cd /tmp/frontend && yarn build

# copy in rest of code
COPY . /varys

RUN mv /tmp/frontend/build /varys/public/app/app

# configure nginx
RUN cp /varys/container_assets/sites-available /etc/nginx/sites-available/default

# Configure log files to go to stdout
RUN ln -sf /dev/stdout /var/log/nginx/access.log &&\
  ln -sf /dev/stderr /var/log/nginx/error.log

CMD ["bundle", "exec", "unicorn_rails", "-c", "config/unicorn.rb"]
