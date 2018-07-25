#!/bin/bash
##
##  APT repository updater
##
##  Leonid Plyushch (C) 2018
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see, <http://www.gnu.org/licenses/>.
##

APT_REPOSITORY_WEB_ROOT="${HOME}/workspace/termux-tools"
APT_REPOSITORY_GPG_KEY="6DF66937649598C1DF8CFA0A9D6D488416B493F0"

##############################################################################
##
##  COMMON FUNCTIONS.
##
##############################################################################

if [ -z "$(command -v apt-ftparchive)" ]; then
    echo "[!] Command 'apt-ftparchive' is not available."
    exit 1
fi

if ! cd "${APT_REPOSITORY_WEB_ROOT}" > /dev/null 2>&1; then
    echo "[!] Failed to move into working directory '${APT_REPOSITORY_WEB_ROOT}'."
    exit 1
fi

## Usage: make_package_list [directory with *.deb files]
make_package_list()
{
    if [ -z "${1}" ]; then
        echo "[!] make_package_list(): missing parameter (\${1})."
        exit 1
    fi

    if [ ! -d "${1}" ]; then
        echo "[!] make_package_list(): path '${1}' is not exists or not a directory."
        exit 1
    fi

    if apt-ftparchive packages "${1}" > "${1}/Packages.tmp" 2>/dev/null; then
        if ! mv -f "${1}/Packages.tmp" "${1}/Packages" > /dev/null 2>&1; then
            echo "[!] make_package_list(): failed to replace '${1}/Packages' with '${1}/Packages.tmp'."
            echo "    Old version of '${1}/Packages' will be used."
        fi
    else
        echo "[!] make_package_list(): apt-ftparchive failed while processing '${1}'."
        echo "    Old version of '${1}/Packages' will be used."
    fi

    if xz -c "${1}/Packages" > "${1}/Packages.xz.tmp" 2>/dev/null; then
        if ! mv -f "${1}/Packages.xz.tmp" "${1}/Packages.xz" > /dev/null 2>&1; then
            echo "[!] make_package_list(): failed to replace '${1}/Packages.xz' with '${1}/Packages.xz.tmp'."
            echo "    Old version of '${1}/Packages.xz' will be used."
        fi
    else
        echo "[!] make_package_list(): failed to compress '${1}/Packages'."
        echo "    Old version of '${1}/Packages.xz' will be used."
    fi
}

## Usage: make_release [directory of distribution] [apt-ftparchive config file]
make_release()
{
    if [ -z "${1}" ]; then
        echo "[!] make_release(): missing parameter (\${1})."
        exit 1
    else
        if [ ! -d "${1}" ]; then
            echo "[!] make_release(): path '${1}' is not exists or not a directory."
            exit 1
        fi
    fi

    if [ -z "${2}" ]; then
        echo "[!] make_release(): missing parameter (\${2})."
        exit 1
    else
        if [ ! -f "${2}" ]; then
            echo "[!] make_release(): path '${2}' is not exists or not a regular file."
            exit 1
        fi
    fi

    if ! apt-ftparchive -c "${2}" release "${1}" > "${1}/Release" 2>/dev/null; then
        echo "[!] make_release(): apt-ftparchive failed while processing '${1}'."
        exit 1
    fi
}

## Usage: sign_release [directory of distribution] [GPG key id]
#sign_release()
#{
#    if [ -z "${1}" ]; then
 #       echo "[!] sign_release(): missing parameter (\${1})."
   #     exit 1
  #  else
  #      if [ ! -d "${1}" ]; then
      #      echo "[!] sign_release(): path '${1}' is not exists or not a directory."
  #          exit 1
  #      fi
 #   fi

#    if [ -z "${2}" ]; then
     #   echo "[!] sign_release(): missing parameter (\${2})."
   #     exit 1
  #  fi

#    if [ ! -f "${1}/Release" ]; then
       # echo "[!] sign_release(): path '${1}/Release' is not exists or not a regular file."
     #   echo "    Is 'make_release()' executed ?"
        #exit 1
 #   fi

  #  if ! gpg --yes -abs -u "${2}" -o "${1}/Release.gpg" "${1}/Release" > /dev/null 2>&1; then
    #    echo "[!] sign_release(): failed to generate a 'Release.gpg'."
#        exit 1
 #   fi

  #  if ! gpg --yes --clearsign -u "${2}" -o "${1}/InRelease" "${1}/Release" > /dev/null 2>&1; then
     #   echo "[!] sign_release(): failed to generate a 'InRelease'."
  #      exit 1
 #   fi
#}

##############################################################################
##
##  REPOSITORY: Termux Mirror
##
##############################################################################


##############################################################################
##
##  REPOSITORY: Extra packages
##
##############################################################################

DISTRIBUTION_SUITE="extras"

for component in main; do
    for arch in all aarch64 arm i686 x86_64; do
        echo "[*] termux-extra (${component}): generating package lists for architecture '${arch}'..."
        make_package_list "dists/${DISTRIBUTION_SUITE}/${component}/binary-${arch}/"

        echo "[*] termux-extra (${component}): generating release..."
        make_release "dists/${DISTRIBUTION_SUITE}/" "$HOME/workspace/apt.conf"

       # echo "[*] termux-extra (${component}): signing release..."
       # sign_release "dists/${DISTRIBUTION_SUITE}/" "${APT_REPOSITORY_GPG_KEY}"
    done
done

##############################################################################

exit 0
