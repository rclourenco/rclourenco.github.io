#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $st = 0;

my @chords;
my $positions = [];
my $name = "";
while (my $line = <STDIN>) {
    chomp $line;
    my $fingers = [];
    if ($st == 0) {
        if ($line =~ /^\s*([x0-9()]+)\s+(.+)/) {
            $name = $2;
            my @ln = split(//, $1);
            foreach my $l (@ln) {
                push @$positions, $l;
            }
            $st = 1;
        }
     } elsif ($st == 1) {
         if ($line =~ /^\s*([-1-4]+)/) {
            my @ln = split(//, $1);
            foreach my $l (@ln) {
                push @$fingers, $l;
            }
             push @chords, {
                'n' => $name,
                    'p' => $positions,
              'f' => $fingers
              };

            $positions = [];
            $name = "";
            $st = 0;
         }   
     }

}

my $text=<<EOT;
<html>
<head>
    <title>Acordes</title>
  <style>
div {
  padding: 10px;
  display: inline-flex;
  justify-content: space-between;
  align-items: center;
}
  </style>
</head>
<body>
EOT

print $text;

my @tmpl = ('-','-','-','-','-','-');

foreach my $c (@chords) {
    
    my ($min, $max) = min_max($c->{p});
    my $nmin = 0;
    if ($min > 1) {
        $nmin = $min - 1;
    }

    my @grid;
    my $d = $max - $nmin;
    if ($d < 5) {
       $d = 5 - $d; 
    } else {
        $d = 0;
    }

    for (my $i=$nmin; $i <= $max+$d; $i++) {
        my @n = @tmpl;
        push @grid, \@n;
    }

    for (my $i = 0; $i<6; $i++) {
        my $p = $c->{p}[$i];
        my $f = $c->{f}[$i];
        if ($p =~ m/^\d+$/) {
            my $r = $p - $nmin;
            if ($r ne "0") {
                $grid[$r][$i] = $f;
            } else {
                $grid[$r][$i] = "0";          
            }
        }
    }
    print "<div class=\"chord\"><pre>\n";
    print $c->{n},"\n";
    show_grid(\@grid, $nmin);
    print "</pre></div>\n";
}

print "</body>\n</html>\n";

sub show_grid {
    my $g = shift;
    my $min = shift;

    my $i=$min;
    print "    . E . A . D . G . B . e .\n"; 
    foreach my $l (@$g) {
        if ($i == 0) {
            print "    |";
            foreach my $x (@$l) {
                if ($x ne '-') {
                    print "=0=|";
                } else {
                    print "===|";
                }
            }
            print "\n";
        } else {
            print sprintf(" %2d |", $i);
            foreach my $x (@$l) {
                if ($x ne '-') {
                    print "-$x-|";
                } else {
                    print "---|";
                }
            }
            print "\n";
        }
        $i++;
    }
}

sub min_max {
    my $s = shift;
    my $min = 100;
    my $max = -1;
    foreach my $d (@$s) {
        if ($d =~ m/^[0-9]+$/) {
            if ($d < $min) {
                $min = $d;
            }

            if ($d > $max) {
                $max = $d;
            }
        }
    }

    return $min, $max;
}

#print Dumper(@chords);
