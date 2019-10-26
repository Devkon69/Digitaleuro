#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

DIGITALEUROD=${DIGITALEUROD:-$SRCDIR/digitaleurod}
DIGITALEUROCLI=${DIGITALEUROCLI:-$SRCDIR/digitaleuro-cli}
DIGITALEUROTX=${DIGITALEUROTX:-$SRCDIR/digitaleuro-tx}
DIGITALEUROQT=${DIGITALEUROQT:-$SRCDIR/qt/digitaleuro-qt}

[ ! -x $DIGITALEUROD ] && echo "$DIGITALEUROD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
DEUROVER=($($DIGITALEUROCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$DIGITALEUROD --version | sed -n '1!p' >> footer.h2m

for cmd in $DIGITALEUROD $DIGITALEUROCLI $DIGITALEUROTX $DIGITALEUROQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${DEUROVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${DEUROVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
