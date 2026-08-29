FROM ruby:3.3.12-bookworm

ARG NODE_VERSION=24.20.0
ARG YARN_VERSION=1.22.19

# `file` already ships in the base image. It is listed because
# active_storage_validations shells out to it to check an upload's bytes
# against its declared content type, which makes it a runtime dependency
# rather than something to inherit by luck.
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      default-libmysqlclient-dev \
      default-mysql-client \
      libxml2-dev libxslt1-dev zlib1g-dev \
      libvips42 \
      file \
      xz-utils curl git tzdata \
 && rm -rf /var/lib/apt/lists/*

# Node from the official tarball rather than an apt repo, so the version is
# pinned here and not by whatever the distro happens to ship.
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
# 2.4's PubGrub resolver settles this dependency graph in seconds; 2.2's
# Molinillo backtracked on it for twenty minutes without converging.
RUN gem install bundler:2.4.22 \
 && bundle config set --local without 'production' \
 && bundle install --jobs 4 --retry 3

COPY package.json yarn.lock* ./
RUN yarn install --check-files

COPY . .

COPY bin/docker-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint
ENTRYPOINT ["docker-entrypoint"]

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
