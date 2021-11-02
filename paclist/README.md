# Paclist

Creates a list of all installed packages in the system separated in three
categories: official, optional and AUR packages. 

It also gives you the ability to reinstall them using this resulting files.

## Usage: 

> `paclist.sh [OPTION]`
>
> Available OPTIONs:
>     --install [folder]
>     install   [folder]
>                         Install packages listed in files:
>                             - Official packages:     '${FILE_OFFICIAL_PKGS}'
>                             - Optional dependencies: '${FILE_OPT_DEPS}'
>                             - AUR packages:          '${FILE_AUR_PKGS}'
>                         Optional argument 'folder' tells where these files 
>                         are.
>
>                         If 'folder' is not specified, the files will be 
>                         picked from the directory with the script.
>                         If any of these files is not found, it'll be skipped.
> 
>     --backup  [folder]
>     bckp      [folder]
>                         List installed packages in these files inside 
>                         'folder':
>                             - Official packages:     '${FILE_OFFICIAL_PKGS}'
>                             - Optional dependencies: '${FILE_OPT_DEPS}'
>                             - AUR packages:          '${FILE_AUR_PKGS}'
>                         If optional argument 'folder' is not specified, the 
>                         files listed above will be stored in the directory 
>                         containing the script.
> 
>     --help
>      -h
>     help
>                         This message.

## License

> The MIT License
> Copyright (c) 2021 Martín E. Zahnd < mzahnd at itba dot edu dot ar >
>     Run `backlight.sh license` to print license text.

