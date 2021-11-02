# Backlight

Configure notebook's monitor backlight using a script.

Currently coded for Intel Backlight driver, altough it should be easily
modified for any other driver by setting the right path in `CURRENT_BRG_PATH`,
and `MAX_BRG_PATH` variables.

## Usage: 

> `backlight.sh [OPTION]`
>
> OPTIONS:
>     i           N
>     inc         N
>     increment   N
>                         Increment brightness by an integer N
> 
>     d           N
>     dec         N
>     decrement   N
>                         Decrement brightness by an integer N
> 
>     s           N
>     set-to      N
>                         Set brightness to be exactly an integer N
> 
>     help
>                         This message.

## License

> The MIT License
> Copyright (c) 2021 Martín E. Zahnd < mzahnd at itba dot edu dot ar >
>     Run `backlight.sh license` to print license text.


