# termux-tools
#### This is unofficial repository for termux 

### List Of Available Packages (Aarch64)
1. hping3
2. libdbus
3. libdbus-glib
4. libgtk2
5. libvte
6. libxfce4ui
7. libxfce4util
8. libxfconf
9. wireless-tools
10. wireshark
11. xfce4-terminal
12. Thunar
13. libexo

### List Of Available Packages (arm)
1. wireless-tools
2. wireshark
3. hping3

### List Of Available Packages (for all platforms)
1. beef-xss
2. xerosploit

#### How To Add My Repo In Sources.list File
1. Add new sources list file `mkdir -p $PREFIX/etc/apt/sources.list.d && printf "deb [trusted=yes] https://hax4us.github.io/termux-tools/ extras main" > $PREFIX/etc/apt/sources.list.d/hax4us.list`
2. Some packages depends on xeffyrs repository packages so in order to use packages from my repository you will have to add this repository also, so follow instructions from here https://termux.xeffyr.ml/extra.html
3. After adding both repositories just  Update `apt update`

#### Inatall Any Package 
`apt install pkg_name`

#### Packages Will Be Add As Per Your Demand Guys :) (Just Open Issue As A Package Request)



