# Polybar Launcher

Launch an instance of Polybar in each connected monitor. 

Different bars for each connected monitor can be specified using the BARS 
array. When there are more monitors than specified bars, whichever is set as
the first one (index 0) in BARS will be launched in the remaining monitors.

> **Note:** By default is set to work only when XDG_CURRENT_DESKTOP environment
> variable is i3. This, of course, can be overriden.

## Usage: 

> `polybar-launch.sh [OPTION]`
>
> OPTIONS:
>     force     Run even if XDG_CURRENT_DESKTOP is not i3
>     debug     Run in debug mode (does not deamonize)

## License

> The MIT License
> Copyright (c) 2021 Martín E. Zahnd < mzahnd at itba dot edu dot ar >

