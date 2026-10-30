<div align="center">

# Handy

> Fork of [dariogriffo/handy-debian](https://github.com/dariogriffo/handy-debian) (MIT); the original packaging is by Dario Griffo. Served at [deb.gaofn.xyz](https://deb.gaofn.xyz) for Debian 12 (bookworm) and 13 (trixie).

**A free, open source, and extensible speech-to-text application that works completely offline.**

![GitHub Release](https://img.shields.io/github/v/release/cjpais/Handy?display_name=tag&color=%23a6a)
![GitHub License](https://img.shields.io/github/license/cjpais/Handy)

</div>

## About

Handy is a cross-platform desktop application for speech-to-text. Press a
configurable global shortcut, speak, and Handy transcribes what you said and
pastes it into whatever application has focus. Everything runs locally: speech
is recognised with Whisper, Parakeet and other models on your own CPU or GPU
(Vulkan), so no audio leaves your machine.

It supports push-to-talk and toggle modes, voice activity detection, custom
vocabulary, a transcription history and optional post-processing of the text
with an LLM provider of your choice.

**The command is `handy`.** Launch it from your desktop's application menu or
run `handy` from a terminal. Speech models are downloaded from inside the app
on first use.

Text input goes through a helper: `xdotool` on X11, `wtype` on most Wayland
compositors (both installed with this package, with `wl-clipboard`). GNOME on
Wayland, the Ubuntu 26.04 default, needs `ydotool` and its daemon running;
it is a recommended package, installed where the suite ships it. See the
upstream README's Linux notes for the ydotool setup.

**[Read the documentation](https://github.com/cjpais/Handy)**
