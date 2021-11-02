# Conky Launcher

Run [`paccache`](https://man.archlinux.org/man/paccache.8) weekly and remove
every version of installed packages except the last two and all uninstalled 
ones, for both pacman and yay caches.

## Usage: 

> `paccache-clean.sh`

Modify the systemd timer according to your needs, as well as the KEEP_UPDATED 
and KEEP_UNINSTALLED variables in the bash script.

## License

> The MIT License
> Copyright (c) 2021 Martín E. Zahnd < mzahnd at itba dot edu dot ar >

