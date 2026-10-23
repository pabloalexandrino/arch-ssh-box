FROM archlinux:base

# Versions pinned here; bump and rebuild to upgrade.
ARG PHP_VERSION=8.4.23
ARG MYSQL_VERSION=8.4.8

# --disable-sandbox: pacman's seccomp sandbox fails under emulated (non-native) builds
RUN pacman -Syu --disable-sandbox --noconfirm --needed openssh zsh tmux git neovim nodejs npm base-devel curl wget ripgrep fzf jq sudo \
        unzip python uv github-cli aws-cli-v2 valkey libaio numactl ncurses libarchive \
    && pacman -Scc --noconfirm

RUN npm i -g @anthropic-ai/claude-code @openai/codex && node /usr/lib/node_modules/@anthropic-ai/claude-code/install.cjs && claude --version && npm cache clean --force

# PHP 8.4 (same major/minor as production): static build, since Arch ships only 8.5 (php) and 8.3 (php-legacy)
RUN curl -fsSL https://dl.static-php.dev/static-php-cli/bulk/php-${PHP_VERSION}-cli-linux-x86_64.tar.gz | tar xz -C /usr/local/bin php \
    && php -v \
    && curl -fsSL https://getcomposer.org/download/latest-stable/composer.phar -o /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer && composer --version

# MySQL 8.4 (same as production); Arch only packages MariaDB
RUN curl -fsSL https://cdn.mysql.com/Downloads/MySQL-8.4/mysql-${MYSQL_VERSION}-linux-glibc2.28-x86_64.tar.xz | tar xJ -C /opt \
    && ln -s /opt/mysql-${MYSQL_VERSION}-linux-glibc2.28-x86_64 /opt/mysql \
    && ln -s /opt/mysql/bin/mysql /opt/mysql/bin/mysqld /opt/mysql/bin/mysqladmin /opt/mysql/bin/mysqldump /usr/local/bin/ \
    && ln -s /usr/lib/libncursesw.so.6 /usr/lib/libncurses.so.6 \
    && mysqld --version && mysql --version

# Release binaries: bun, rtk, ai-memory, AWS session-manager-plugin (SSM tunnels)
RUN curl -fsSL https://github.com/oven-sh/bun/releases/latest/download/bun-linux-x64.zip -o /tmp/bun.zip \
    && bsdtar -xf /tmp/bun.zip -C /tmp && install -m755 /tmp/bun-linux-x64/bun /usr/local/bin/bun \
    && curl -fsSL https://github.com/rtk-ai/rtk/releases/latest/download/rtk-x86_64-unknown-linux-musl.tar.gz | tar xz -C /usr/local/bin rtk \
    && curl -fsSL https://github.com/akitaonrails/ai-memory/releases/latest/download/ai-memory-linux-x86_64.tar.gz | tar xz -C /tmp ./ai-memory \
    && install -m755 /tmp/ai-memory /usr/local/bin/ai-memory \
    && curl -fsSL https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm -o /tmp/smp.rpm \
    && bsdtar -xf /tmp/smp.rpm -C /tmp && install -m755 /tmp/usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/ \
    && rm -rf /tmp/* \
    && bun --version && rtk --version && ai-memory --version && session-manager-plugin --version

RUN useradd -m -s /usr/bin/zsh pablo \
    && echo 'pablo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/pablo \
    && mkdir -p /home/pablo.skel && cp -a /home/pablo/. /home/pablo.skel/
COPY zshrc /home/pablo.skel/.zshrc
COPY sshd_config /etc/ssh/sshd_config.d/10-hardening.conf
COPY box-services /usr/local/bin/box-services
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/box-services
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
