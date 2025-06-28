FROM ghcr.io/ublue-os/bluefin:latest
# These labels provide useful information about your custom image layer.
LABEL org.opencontainers.image.title="Custom Bluefin Minimal-CE N4020"
LABEL org.opencontainers.image.authors="itsreduxtm@example.com" 
LABEL org.opencontainers.image.description="Optimized Bluefin OS image for low-RAM Celeron N4020 systems with zram, built as an rpm-ostree layer."
LABEL org.opencontainers.image.url="https://github.com/itsreduxtm/bluefin"
LABEL org.opencontainers.image.source="https://github.com/ublue-os/bluefin"
LABEL org.opencontainers.image.created="$(date --iso-8601=seconds)"
# --- Layering RPM Packages with rpm-ostree ---
# 'rpm-ostree install' adds packages as an overlay to the immutable base.
# The selection below is based on your provided list, focusing on essentials and tools
# that are common or requested, while being mindful of resource usage.
# Each package adds to the image size and potential runtime memory.
    

# --- Masking Unnecessary Services ---
# 'systemctl mask' creates a symlink to /dev/null for a service file, preventing it
# from being started, even by other services. This is crucial for minimal systems
# and helps reduce boot time and active resource consumption for services you don't need.
    # Consider masking more services if your system is truly headless or very minimal: 
    # gnome-initial-setup.service \
    # geoclue.service \
    # systemd-localed.service \
    # systemd-homed.service \
    # rtkit-daemon.service \
    # bolt.service \
    # colord.service \
    # gdm.service \
RUN systemctl enable \
    chronyd.service \
    systemd-oomd.service \
    firewalld.service \
    upower.service \
    systemd-resolved.service \
    # Add any other critical services your specific setup requires to be enabled by default.
    

