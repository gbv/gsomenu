use strict;
use warnings;
package GBV::RDF::Source::DBInfoYAML; 

use Log::Contextual::WarnLogger;
use Log::Contextual qw(:log), -default_logger 
    => Log::Contextual::WarnLogger->new({ env_prefix => 'GBV_RDF_SOURCE_DBINFOYAML' });

use YAML::Any qw(LoadFile);
use parent 'RDF::Flow::Source';

use RDF::Trine::Model;
use RDF::Trine qw(iri statement literal blank);

use Try::Tiny;

use RDF::NS::Trine;
use constant NS => RDF::NS::Trine->new('20120521');

# load configuration

sub new {
    my ($class, $file) = @_;

    my $error = "";
    my $dbs = try { LoadFile($file)->{databases}; } catch { $error = $_; { } };
    $dbs = { } unless (ref($dbs)||'') eq 'HASH';

    if ($error) {
        log_warn { "failed to load from $file: $error" };
    } else {
        log_trace { "loaded from $file" };
    }

    return bless { databases => $dbs }, $class;
}

sub retrieve_rdf {
    my ($self, $env) = @_;
    my $uri = $env->{'rdflow.uri'};

    return unless $uri =~ qr{^http://uri.gbv.de/database/([a-z][a-z0-9_-].+)};
    my $key = $1;
    my $db = $self->{databases}->{$key} or return;
    return unless (ref($db) || '') eq 'HASH';
    my $dburi = iri($uri);

    log_info { "retrieve dbkey $key" };

    my @triples = (
        [ $dburi, NS->gbv_dbkey, literal($key) ],
        [ $dburi, NS->rdf_type, NS->daia_Service ],
#        [ $dburi, NS->rdf_type, NS->cdtype_CatalogueOrIndex ],
        [ $dburi, NS->rdf_type, NS->void_Dataset ],
    );

    if ( $db->{title} ) {
        push @triples, [ $dburi, NS->dcterms_title, literal($db->{title}, 'de') ];
    }
    if ( $db->{title_en} ) {
        push @triples, [ $dburi, NS->dcterms_title, literal($db->{title_en}, 'en') ];
    }
    my $access = $db->{access};
    if ($access) {
        if ($access =~ /^https?:/) {
            push @triples, [ $dburi, NS->foaf_homepage, iri($access) ];
        }
    }
    if ($db->{info}) {
        push @triples, [ $dburi, NS->foaf_isPrimaryTopicOf, iri($db->{info}) ];
    }

    push @triples, [ $dburi, NS->rdf_type, NS->daiaserv_Openaccess ];

    my $model = RDF::Trine::Model->new;
    add_statements($model, \@triples);

    return $model;
}

# TODO: helper function in other module
sub add_statements {
    my ($model, $statements) = @_;

    $model->begin_bulk_ops;
    foreach (@$statements) {
        $_ = statement(@$_) if ref $_ eq 'ARRAY';
        $model->add_statement( $_ );
    }
    $model->end_bulk_ops;
    return $model;
}


1;
