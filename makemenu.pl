#!/usr/bin/perl
#ABSTRACT: Collect GBV database information for GSO-Menu
use v5.14.2;

use Config::ZOMG;
use Hash::Merge qw(merge);
use Scalar::Util qw(reftype);
use Data::Dumper;
use JSON;
use File::Slurp qw(write_file);
use RDF::Flow::LinkedData;
use RDF::Lazy;
use RDF::NS;
use constant NS => RDF::NS->new('20120917');

# load config files
my ($menu, $dblist) = map {
    if ( my $c = Config::ZOMG->open( file => $_ ) ) {
        say "loaded config file $_"; $c;
    } else {
        die "failed to load config file $_: $@\n";
    }   
} ('menu.yaml', 'dblist.yaml');

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
			if ($m->{databases}) {
				if (ref $m->{databases}) {
					$db->{databases} = expand($m->{databases});
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
				$dblist->{$m} // { },
				{ dbkey => $m },
			);
		}
	};
}

my $LOD = RDF::Flow::LinkedData->new;

# expand databases
my $fullmenu = { 
	databases => expand( $menu->{databases} ) 
};

# TODO: write only if no error:

write_file('gsomenu.json',to_json($fullmenu, { utf8 => 1, pretty => 1 }));

sub retrieve {
    my $dbkey = shift || return '';
    my $uri = "http://uri.gbv.de/database/$dbkey";
	print $uri;
    
	my $rdf  = $LOD->retrieve($uri);

	my $db = { };

    if ($rdf->size) { 
        my $lazy = RDF::Lazy->new( $rdf, namespaces => NS );
		my $dbrdf = $lazy->resource($uri); 

		my ($title_de) = $dbrdf->dcterms_title('@de','');
		my ($title_en) = $dbrdf->dcterms_title('@en');
		my ($access)   = $dbrdf->gbv_picabase;

		$db->{title_de} = $title_de->str if defined $title_de;
		$db->{title_en} = $title_en->str if defined $title_en;
		$db->{access}   = $access->str   if defined $access;
	
		# TODO: info-URL 
    }
	say (keys %$db ? " - ok" : " - not found");
	return $db;
}

sub expand_list {
	my $db = shift;
	$db->{databases} = [ ];

	foreach my $prefix (@_) {
		my $uri = "http://uri.gbv.de/database/$prefix";
		my $rdf = $LOD->retrieve( $uri );
		$rdf = RDF::Lazy->new( $rdf, namespaces => NS )->resource($uri);

		if ( $rdf->type('skos:Concept') ) {
			if (!$db->{title_de}) {
				my ($title_de) = $rdf->dcterms_title('@de','') || $rdf->skos_prefLabel('@de','');
				$db->{title_de} = $title_de->str if defined $title_de;
			}
			if (!$db->{title_en}) {
				my ($title_en) = $rdf->dcterms_title('@en')    || $rdf->skos_prefLabel('@en');
				$db->{title_en} = $title_en->str if defined $title_en;
			}
			# TODO: info-URL 

			foreach ( @{ $rdf->revs('dc:subject') } ) {
				next unless $_ =~ s{^http://uri.gbv.de/database/}{};
				push @{$db->{databases}}, expand($_);
			}
		} else { 
			# single database
			push @{$db->{databases}}, expand($prefix);
		}
	}
}
