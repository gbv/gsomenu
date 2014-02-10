#!/usr/bin/env perl
#ABSTRACT: Collect GBV database information for GSO-Menu
use v5.10;
use strict;

use Config::Any;
use Hash::Merge qw(merge);
use Scalar::Util qw(reftype);
use JSON;
use File::Slurp qw(write_file);
use RDF::Lazy 0.081;
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

	given ( reftype($m) ) {
		when ('ARRAY') {
			return [ map { expand($_) } @$m ];
		}
		when ('HASH') {
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
		}
		default {
			return merge(
				retrieve( $m ),
				$dblist->{$m},
			);
		}
	};
}

#my $x = expand('gvk');
#my $x = $dblist->{'gvk'};
#say to_json $x;

# expand databases
my $fullmenu = { 
	databases => expand( $menu->{databases} ) 
};

# TODO: write only if no error:

write_file($output,to_json($fullmenu, { pretty => 1 }));

sub retrieve {
    my $dbkey = shift || return '';
    my $uri = "http://uri.gbv.de/database/$dbkey";

	print $uri;
    
	my $rdf  = RDF::Lazy->new($uri, namespaces => '20120917');

	my $db = { dbkey => $dbkey, uri => $uri };

    if ($rdf->size) { 
		my $dbrdf = $rdf->resource($uri); 

        rdf2db( $dbrdf => $db );
    }

	say (keys %$db ? " - ok" : " - not found");

	return $db;
}

sub rdf2db {
    my $rdf = shift;
    my $db = shift;

    # encode_utf8 only for Perl <= 5.10??
	my $title_de = "".($rdf->dcterms_title('@de','') || $rdf->skos_prefLabel('@de','') || "");
	my $title_en = "".($rdf->dcterms_title('@en')    || $rdf->skos_prefLabel('@en')    || "");
    my $access   = ("".$rdf->gbv_picabase) || "";

    ($title_en, $title_de, $access) = map { encode_utf8($_) } ($title_en, $title_de, $access);
    print " $title_de ";

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
		my $rdf = RDF::Lazy->new( $uri )->resource($uri);

        rdf2db( $rdf => $db );

		if ( $rdf->type('skos:Concept') ) {

			foreach ( @{ $rdf->revs('dc:subject') } ) {
				next unless $_ =~ s{^http://uri.gbv.de/database/}{};
				push @{$db->{databases}}, expand($_);
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
