#!/bin/sh

echo " acordes.txt"
echo "-------------"
perl -pe "system 'sleep .2'" acordes.txt
echo ""
echo " chorddiagram.pl"
echo "----------------"
perl -pe "system 'sleep .2'" chorddiagram.pl
echo ""
echo "Running: "
echo "cat acordes.txt | perl chorddiagram.pl > acordes.html"
cat acordes.txt | perl chorddiagram.pl > acordes.html
sleep 1
open -a "Google Chrome" acordes.html
