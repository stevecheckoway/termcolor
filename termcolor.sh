#!/bin/bash

exec 3<> /dev/tty
oldstty=$(stty -g <&3)
stty raw -echo min 0 <&3
IFS=':/' read -t 1 -p $'\033]11;?\007' -d $'\007' -r escrgb red green blue 2>&3 <&3
stty "${oldstty}" <&3
if [[ "${escrgb}" == $'\033]11;rgb' ]]; then
  # Each of red, green, and blue are 1, 2, or 4 hexadecimal digits and they
  # may not even be the same length. If red is a single digit, then it
  # represents the value R = red/15. If it is two digits, then it represents the
  # value R = red/255 and if it's four digits, then it represents R =
  # red/65535. In all cases, we have R in [0, 1]. Green and blue are similar.
  # If (R + G + B) / 3 < .5, then we say the background is dark, otherwise it
  # is light.
  #
  # Since Bash doesn't support fractional numbers, we need to work with
  # integers. Let x, y, and z be the integers such that
  #   R = red / x, 
  #   G = green / y, and
  #   B = blue / z.
  # Note that x, y, and z are integers in {15, 255, 65535}.
  #
  # We can rewrite (R + G + B) / 3 < .5 as
  #   2 * (R + G + B) < 3
  #   2 * (R + G + B) * 65535 < 3 * 65535
  #   2 * (red*(65535/x) + green*(65535/y) + blue*(65535/z) < 3 * 65535
  #
  # Conveniently, 65535/15, 65535/255, and 65535/65535 are all integers.
  #
  # We can compute x, y, and z by the length of red, green, and blue.
  (( x = (1 << 4*${#red}) - 1 ))
  (( y = (1 << 4*${#green}) - 1 ))
  (( z = (1 << 4*${#blue}) - 1 ))
  if (( 2 * ("0x${red}"   * (65535/x) + \
             "0x${green}" * (65535/y) + \
             "0x${blue}"  * (65535/z) ) < 196605 )); then
    echo 'dark'
  else
    echo 'light'
  fi
else
  echo 'unknown'
  exit 1
fi
