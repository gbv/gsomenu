#!/usr/bin/env perl
use strict;
use warnings;
use v5.10;

use JSON;
use Text::CSV;
my $db = from_json( do { local $/; <> } );

my @rows = [qw(dbkey title_de title_en url)];

walk ($db->{databases});

sub walk {
    for (@{$_[0]}) {
        if ($_->{databases}) {
            walk($_->{databases});
        } else {
            push @rows, [ $_->{dbkey}, $_->{title_de}, $_->{title_en}, $_->{access} ];
        }
    }
}

my $csv = Text::CSV->new( { eol => "\r\n" } );
open my $fh, ">", "alle-gsomenu-datenbanken.csv";
print $fh "\xEF\xBB\xBF"; # BOM
$csv->print($fh, $_) for @rows;
close $fh;

