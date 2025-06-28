syntax=docker/dockerfile:1.4
# Dockerfile for Creating a Custom Bluefin OSTree Image Layer
#
# This Dockerfile is designed to build a new immutable OS image based on Bluefin,
# tailored for low-resource systems like your Celeron N4020 with 4GB RAM and ZRAM.
# It leverages rpm-ostree for atomic package management and system modifications.
#
# The resulting image is intended for use with `rpm-ostree rebase` or `rpm-ostree ex-container`
# on a Bluefin host, NOT to be run directly as a typical Docker application container.

# --- Base Image: Official Bluefin from ghcr.io ---
# This pulls the latest Bluefin OSTree image, which is the foundation for your custom layer.
# As confirmed, ghcr.io is the official and primary distribution channel for Universal Blue images.
FROM ghcr.io/ublue-os/bluefin:latest

# --- Image Metadata (Labels) ---
# These labels provide useful information about your custom image layer.
LABEL org.opencontainers.image.title="Custom Bluefin Minimal-CE N4020"
LABEL org.opencontainers.image.authors="itsreduxtm@example.com" # Updated author email placeholder
LABEL org.opencontainers.image.description="Optimized Bluefin OS image for low-RAM Celeron N4020 systems with zram, built as an rpm-ostree layer."
LABEL org.opencontainers.image.url="https://github.com/itsreduxtm/bluefin" # Link to your new repository
LABEL org.opencontainers.image.source="https://github.com/ublue-os/bluefin" # Source of the base Bluefin image
LABEL org.opencontainers.image.created="$(date --iso-8601=seconds)" # Automatically adds build date/time

# --- Layering RPM Packages with rpm-ostree ---
# 'rpm-ostree install' adds packages as an overlay to the immutable base.
# The selection below is based on your provided list, focusing on essentials and tools
# that are common or requested, while being mindful of resource usage.
# Each package adds to the image size and potential runtime memory.
RUN rpm-ostree install \
    zfs \
    upower \
    lm_sensors \
    chrony \
    firewalld \
    gnome-system-monitor \
    neovim \
    podman \
    flatpak \
    zsh \
    wireguard-tools \
    openssh-server \
    tailscale \
    git \
    toolbox \
    vim-enhanced \
    gnome-control-center \
    gnome-shell-extension-dash-to-dock \
    ffmpeg \
    htop \
    curl \
    wget \
    tmux \
    unzip \
    rsync \
    fuse3 \
    fzf \
    just \
    bash-completion \
    util-linux \
    gvfs \
    udisks2 \
    pipewire \
    libvirt-daemon \
    # Add any other specific RPM packages you need for your Chromebox setup.
    # Keep this list as lean as possible to conserve RAM and disk space.
    && true

# --- Masking Unnecessary Services ---
# 'systemctl mask' creates a symlink to /dev/null for a service file, preventing it
# from being started, even by other services. This is crucial for minimal systems
# and helps reduce boot time and active resource consumption for services you don't need.
RUN systemctl mask \
    ModemManager.service \
    bluetooth.service \
    cups.service \
    cups.socket \
    avahi-daemon.service \
    avahi-daemon.socket \
    pcscd.socket \
    sssd.service \
    cockpit.service \
    flatpak-system-update.timer \
    brew-setup.service \
    brew-update.timer \
    brew-upgrade.timer \
    # Consider masking more services if your system is truly headless or very minimal:
    # gnome-initial-setup.service \
    # geoclue.service \
    # systemd-localed.service \
    # systemd-homed.service \
    # rtkit-daemon.service \
    # bolt.service \
    # colord.service \
    # gdm.service \
    && true

# --- Enabling Essential Services/Timers ---
# 'systemctl enable' ensures these services will be active on boot.
# These are services that you explicitly want running for stability, security, or core functionality.
RUN systemctl enable \
    chronyd.service \
    systemd-oomd.service \
    firewalld.service \
    upower.service \
    systemd-resolved.service \
    # Add any other critical services your specific setup requires to be enabled by default.
    && true

# --- Set Default Shell for Root (Optional but Recommended) ---
# Changes the default shell for the root user. Useful for interactive sessions via SSH or console.
RUN usermod --shell /usr/bin/zsh root

# --- Customizations (Example: Adding a custom script or configuration) ---
# If you have custom scripts, configurations, or binaries you want to include in your
# OSTree image layer, you would add them here. For a minimalist approach, keep this
# to an absolute minimum.
# Example: Adding a custom startup script for a specific hardware tweak.
# COPY scripts/my-chromebox-tweak.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/my-chromebox-tweak.sh
# Example: Adding a custom systemd service for your tweak.
# COPY systemd/my-chromebox-tweak.service /etc/systemd/system/
# RUN systemctl enable my-chromebox-tweak.service

# --- Important Final Note ---
# This Dockerfile creates a *container image*. To apply this custom image
# to your Bluefin OS installation, you will use `rpm-ostree` commands on your
# *host system*.
#
# Build the image (typically using podman):
# podman build -t ghcr.io/itsreduxtm/bluefin:latest .
#
# Push the image to GitHub Container Registry (requires ghcr.io login):
# podman push ghcr.io/itsreduxtm/bluefin:latest
#
# Then, on your Bluefin OS system, rebase to your custom image:
# rpm-ostree rebase ostree-unverified-registry:ghcr.io/itsreduxtm/bluefin:latest
#
# Reboot to apply the changes:
# systemctl reboot
