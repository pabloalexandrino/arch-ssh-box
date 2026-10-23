FROM archlinux:base
RUN pacman -Syu --noconfirm --needed openssh zsh tmux git neovim nodejs npm base-devel curl wget ripgrep fzf jq sudo \
    && pacman -Scc --noconfirm
RUN npm i -g @anthropic-ai/claude-code @openai/codex && node /usr/lib/node_modules/@anthropic-ai/claude-code/install.cjs && claude --version && npm cache clean --force
RUN useradd -m -s /usr/bin/zsh pablo \
    && echo 'pablo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/pablo \
    && mkdir -p /home/pablo.skel && cp -a /home/pablo/. /home/pablo.skel/
COPY zshrc /home/pablo.skel/.zshrc
COPY sshd_config /etc/ssh/sshd_config.d/10-hardening.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
