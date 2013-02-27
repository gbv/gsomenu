#!/usr/bin/perl

use strict;
use warnings;
use v5.10.1;

use Config::ZOMG;
use Data::Rmap;
use Data::Dumper;
use Moo;
use JSON;

my ($menu, $dblist) = map {
    if ( my $c = Config::ZOMG->open( file => $_ ) ) {
        say "loaded config file $_";
        $c;
    } else {
        die "failed to load config file $_: $@\n";
    }   
} ('menu.yaml', 'dblist.yaml');

my $fullmenu = handle( $menu );

sub handle {
    my $m = shift;
    my @databases;

    my $db = {
        title => $m->{title},
        titleen => $m->{titleen},
    };

    if ($m->{databases}) {
        $db->{databases} = [ ];
        $db->{sorted}    = $m->{sorted};
        foreach my $child (@{ $m->{databases} }) {
                
        }
    }

    return $db;
}

say to_json($fullmenu, {utf8 => 1, pretty => 1});

exit;
__END__
# required CPAN modules
use YAML qw(LoadFile);
use RDF::Trine qw(iri);
use RDF::Trine::Iterator qw(smap);
use RDF::Trine::Model;
use RDF::Trine::Parser;
use Data::Dumper;
use RDF::Dumper;
use CHI;
use CGI qw(:html escapeHTML);
use Template;
use RDF::Flow qw(cached union);
use RDF::Flow::LinkedData;
use RDF::Lazy;

use RDF::NS;
use constant NS => RDF::NS->new('20120521');

use File::Spec::Functions qw(catdir catfile rel2abs);
use File::Basename qw(dirname);
use lib rel2abs(catdir(dirname($0),'lib'));
chdir rel2abs(dirname($0));

use GBV::RDF::Source::DBInfoYAML;

my $outfile = shift @ARGV || "index.html";
die 'Output file must be .html' unless $outfile =~ /\.html$/;

my $errors;
sub error { print STDERR $_[0] . "\n"; $errors++; }

# load configuration
my $config = "menu.yaml";
my $dbs = LoadFile($config)->{databases};
@$dbs = grep { (ref($_) || 'HASH') eq 'HASH' } @$dbs;

# get database information as Linked Data

# temporär, solange nicht-PICA-Datenbanken nicht in der Konfiguration sind
my $yamlsource = GBV::RDF::Source::DBInfoYAML->new("dblist.yaml");

my $dbsource = cached( 
    union( RDF::Flow::LinkedData->new, $yamlsource ), 
    CHI->new( driver => 'RawMemory', global => 1 ) 
);

my $template = join('',<DATA>);
my $tt = Template->new( INTERPOLATE => 1, TRIM => 1, RECURSION => 1 );
our $dbcount;

sub dbentry {
    my $key = shift || return '';
    my $uri = "http://uri.gbv.de/database/$key";
    my $db  = $dbsource->retrieve($uri);
    if ($db->size) { 
        $dbcount++;
        my $output = '';
        $db = RDF::Lazy->new( $db, namespaces => NS );
        $tt->process( 'dbentry.tt', { db => $db->resource($uri) }, \$output )
            || error( $tt->error );
        return $output;
    } else {
        error( "could not get database/prefix: $key" );
        return "<!-- could not get database/prefix: $key -->\n";
    }
}

my $infoimg = '<img alt="info" title="info" src="http://www.gbv.de/gsomenu/img/info.gif" border="0" width="19" height="11">';

our @html;

sub handle_entry {
    my $entry = shift;

    unless (ref $entry) { # simple dbkey
        push @html, dbentry($entry);
        return;
    }

    my $title     = $entry->{title};
    my $info      = $entry->{info};
    my $databases = $entry->{databases};
    my $access    = $entry->{access};
    my $sorted    = $entry->{sorted};
    my @dbs;

    if (ref $databases) {
        @dbs = grep { defined } @$databases;
    } elsif( $databases ) {
        foreach my $prefix (split /\s*\|\s*/, $databases) {
            my $uri = "http://uri.gbv.de/database/$prefix";
            my $rdf = $dbsource->retrieve( $uri );
            $rdf = RDF::Lazy->new( $rdf, namespaces => NS )->resource($uri);

            unless ($rdf->type('skos:Concept')) {
                push @dbs, $prefix;
                next;
            }

            $title = (eval { $rdf->dcterms_title->str } 
                        || eval { $rdf->skos_prefLabel->str } || "" ) unless $title;

            foreach ( @{ $rdf->revs('dc:subject') } ) {
                next unless $_ =~ s{^http://uri.gbv.de/database/}{};
                push @dbs, $_;
            }
        }
    }

    if (!$title) {
        error( "Missing title of $databases" );
        $title = "Datenbanken";
    }

    if ($access) {
        push @html, '<li><a class="dbentry" href="' . escapeHTML($access) . '">' . escapeHTML($title) . '</a>';
    } else {
        push @html, '<li>' . escapeHTML($title);
    }
    push @html, " <a href='$info'>$infoimg</a>" if $info;
 
    if (@dbs) { 
        push @html, ($sorted ? '<ul class="dbsorted">' : '<ul>');
        foreach my $e (@dbs) {
            handle_entry($e);
        }
        push @html, "</ul>\n";
    }
    push @html, "</li>\n";

}

@html = "<ul>";
foreach my $entry (@$dbs) {
    handle_entry($entry);
}
push @html, "</ul>";

my $dblist = join "", @html, '';

write_file( 'index.html' );

sub write_file {
    my ($outfile = shift;
    my $tmpout = $outfile;
    $tmpout =~ s/\.html$/-neu.html/;
    print STDERR "writing list to $outfile\n";
    if ( $tt->process( 'gsomenu.tt', { dblist => $dblist }, $tmpout ) and $dbcount > 10 ) {
        if ($errors) {
            print STDERR "Output is at $tmpout because of errors\n";
        } else {
            system ("cp $tmpout $outfile");
        }
    }
}

