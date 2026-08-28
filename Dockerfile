# Ruby 2.7.1 to match .ruby-version. The image is Debian Buster, which has
# reached end of life, so apt sources are repointed at the Debian archive.
FROM ruby:2.7.1

ARG NODE_VERSION=14.21.3
ARG YARN_VERSION=1.22.19

RUN sed -i -e 's|deb.debian.org|archive.debian.org|g' \
           -e 's|security.debian.org|archive.debian.org|g' \
           -e '/buster-updates/d' /etc/apt/sources.list \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      default-libmysqlclient-dev \
      default-mysql-client \
      libxml2-dev libxslt1-dev zlib1g-dev \
      xz-utils curl git tzdata \
 && rm -rf /var/lib/apt/lists/*

# Node from the official tarball; the NodeSource apt repo no longer serves Buster.
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
      amd64) NODE_ARCH=x64 ;; \
      arm64) NODE_ARCH=arm64 ;; \
      *) echo "unsupported arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
      | tar -xJ -C /usr/local --strip-components=1 --exclude=CHANGELOG.md --exclude=LICENSE --exclude=README.md; \
    npm install -g "yarn@${YARN_VERSION}"; \
    node --version; yarn --version

WORKDIR /app

COPY Gemfile Gemfile.lock ./
# The committed lockfile pins nokogiri to x86_64-linux. Register the other
# platforms so the image builds on Apple Silicon as well as on x86.
RUN gem install bundler:2.2.25 \
 && bundle lock --add-platform x86_64-linux aarch64-linux ruby \
 && bundle config set --local without 'production' \
 && bundle install --jobs 4 --retry 3

COPY package.json yarn.lock* ./
# Transitive deps published since 2021 advertise newer Node engines than this
# 2021-era toolchain uses. They run fine; sass is pinned in package.json
# because its newer releases genuinely will not run on Node 14.
RUN yarn install --check-files --ignore-engines

COPY . .

COPY bin/docker-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint
ENTRYPOINT ["docker-entrypoint"]

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
