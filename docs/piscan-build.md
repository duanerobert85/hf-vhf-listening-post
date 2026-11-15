# Building PiScan with ALSA

```bash
git clone https://github.com/ezratl/PiScan.git
cd PiScan
sh ./configure_make
cd build
cmake .. -DUSE_AUDIO_ALSA=ON
make piscan_server
sudo make install   # optional, or run from build dir
```

On first clean exit, config.json and state.json are created in the data directory.

Copy or symlink systems.json into the data directory before scanning.

Edit config.json to set:
- ppm_correction for the NESDR SMArt
- sample_rate (2048000 recommended start)
