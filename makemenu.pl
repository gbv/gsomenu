#!/usr/bin/env perl
#ABSTRACT: Collect GBV database information for GSO-Menu
use v5.10;
use strict;

use Config::Any;
use Hash::Merge qw(merge);
use Scalar::Util qw(reftype);
use JSON;

use RDF::aREF '0.21';
use RDF::Trine;

use Encode;

#binmode *STDOUT, 'utf8';

#my $output = 'test.json'; 
my $output = 'gsomenu.json'; 

# load config files
my ($menu, $dblist) = map {
    my $c = Config::Any->load_files({ files => [ $_ ], use_ext => 1 });
    if ($c && $c->[0]->{$_}) { 
        say "loaded config file $_"; 
        $c->[0]->{$_};
    } else {
        die "failed to load config file $_: $@\n";
    }   
} ('menu.yaml', 'databases.csv');

# expand menu
sub expand {
    my $m = shift;

	if ( reftype $m and reftype $m eq 'ARRAY' ) {
		return [ map { expand($_) } @$m ];
	} elsif ( reftype $m and reftype $m eq 'HASH' ) {
        my $db = {
            title_de => $m->{title_de},
            title_en => $m->{title_en},
            access   => $m->{access},
            info   	 => $m->{info},
        };
        say "# ".$db->{title_de};
        $db->{sorted} = $m->{sorted} if $m->{sorted};
        if ($m->{databases}) {
            if (ref $m->{databases}) {
                $db->{databases} = expand( $m->{databases} );
            } else {
                expand_list(
                    $db,
                    split /\s*\|\s*/, $m->{databases}
                );
            }
        }
        return $db;
	} else {
        return merge(
            retrieve( $m ),
            $dblist->{$m},
        );
	}
}

#my $x = expand('gvk');
#my $x = $dblist->{'gvk'};
#say to_json $x;

# expand databases
my $fullmenu = { 
	databases => expand( $menu->{databases} ) 
};

# TODO: write only if no error:

open my $fh, '>', $output;
print $fh to_json($fullmenu, { pretty => 1, canonical => 1 });

sub retrieve {
    my $dbkey = shift || return '';
    my $uri = "http://uri.gbv.de/database/$dbkey";

	print $uri;
    
	my $db = { dbkey => $dbkey, uri => $uri };
    rdf2db( encode_aref($uri), $uri => $db );

	say (keys %$db ? " - ok" : " - not found");

	return $db;
}

sub rdf2db {
    my ($rdf, $uri, $db) = @_;

	my ($title_de) = aref_query($rdf, $uri, qw(
        dct_title@de skos_prefLabel@de dct_title@ skos_prefLabel@));
	my ($title_en) = aref_query($rdf, $uri, 'dct_title@en', 'skos_prefLabel@en');
    my ($access)   = aref_query($rdf, $uri, 'gbv_picabase');

    print " $title_de : $access";

    if (!$db->{title_de}) {
        $db->{title_de} = $title_de if $title_de;
    }

    if (!$db->{title_en}) {
        $db->{title_en} = $title_en if $title_en;
    }

    if ($access) {
        if ($access =~ qr{/DB=[0-9.]+[/]?$}) {
            $access .= '{?LNG}';
        }
        $db->{access} = $access;
    }

    # TODO: info-URL 
}

sub expand_list {
	my ($db, @prefixes) = @_;
	$db->{databases} = [ ];

	foreach my $prefix (@prefixes) {
		my $uri = "http://uri.gbv.de/database/$prefix";
		my $rdf = encode_aref $uri;
        rdf2db( $rdf, $uri => $db );

        # '$uri a skos_Concept'
		if ( grep { $_ eq 'http://www.w3.org/2004/02/skos/core#Concept' } 
                aref_query($rdf,$uri,'a') ) {
			foreach my $s ( keys %$rdf ) {
                # $s dc_subject $uri
                next unless ( grep { $_ eq $uri } aref_query $rdf, $s, 'dc_subject' );
				next unless $s =~ s{^http://uri.gbv.de/database/}{};
				push @{$db->{databases}}, expand($s);
			}
		} else { 
			# single database
			push @{$db->{databases}}, expand($prefix);
		}
	}

    if (@prefixes == 1) {
        $db->{dbkey} = $prefixes[0];
		$db->{uri}   = "http://uri.gbv.de/database/$prefixes[0]";
    }

    $db = merge( $db, map { $dblist->{$_} // { } } @prefixes );
}
