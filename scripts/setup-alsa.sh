#!/bin/bash
# Helper to identify and set default ALSA device
echo "Playback devices:"
aplay -l
echo
echo "Create /etc/asound.conf using config/asound.conf.template"
echo "Then test with: speaker-test -c 2 -t wav"
echo "Save mixer state: sudo alsactl store"
