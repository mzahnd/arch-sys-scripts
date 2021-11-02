# Conky Launcher

Launch an instance of conky in each connected monitor. 

More than one configuration files are allowed and a conky instance will be 
launched for every one of them (per monitor).

> **Note:** By default is set to work only when XDG_CURRENT_DESKTOP environment
> variable is i3. This, of course, can be overriden.

## Usage: 

> `conky-launch.sh [OPTION]`
>
> OPTIONS:
>     force     Run even if XDG_CURRENT_DESKTOP is not i3
>     debug     Run in debug mode (does not deamonize)

## License

> The MIT License
> Copyright (c) 2021 Martín E. Zahnd < mzahnd at itba dot edu dot ar >

