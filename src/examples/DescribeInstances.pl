#!/usr/bin/env perl

package Amazon::CLI::EC2;

use strict;
use warnings;

use Amazon::EC2;
use Data::Dumper;
use English qw{ -no_match_vars };
use Term::ANSIColor;
use Text::ASCIITable;
use Furl;
use Data::Dumper;
use Carp;
use Carp::Always;

use ReadonlyX;

Readonly our $TRUE  => 1;
Readonly our $FALSE => 0;

Readonly our $EMPTY     => q{};
Readonly our $OCTOTHORP => q{#};

Readonly::Hash our %COLORS => (
  running    => 'green',
  terminated => 'red',
  stopped    => 'magenta',
  pending    => 'yellow',
);

our $VERSION = '0.01';

caller or __PACKAGE__->main();

########################################################################
sub main {
########################################################################

  my $ec2 = Amazon::EC2->new( { user_agent => Furl->new } );

  my $result = eval { return $ec2->DescribeInstances; };

  if ( $EVAL_ERROR && ref($EVAL_ERROR) =~ /API::Error/xsm ) {
    print Dumper( [ $EVAL_ERROR->get_response, $EVAL_ERROR->get_error ] );
  }
  elsif ($EVAL_ERROR) {
    croak $EVAL_ERROR;
  }

  my $t = Text::ASCIITable->new(
    { headingText => 'EC2 Instances', allowANSI => $TRUE } );

  $t->setCols( $OCTOTHORP, 'instanceId', 'name', 'imageId',
    'instanceType', 'privateIpAddress', 'launchTime', 'instanceState' );

  my @data;

  foreach my $item ( @{ $result->{'reservationSet'}->{'item'} } ) {
    push @data, $item->{'instancesSet'}->{'item'}->[0];
  }

  # sort by state (running)
  @data
    = sort { $a->{'instanceState'}->{'name'} eq 'running' ? -1 : 1 } @data;

  my $row = 0;

  foreach my $item (@data) {
    my $state = $item->{'instanceState'}->{'name'};

    my $name = $item->{'tagSet'}->{'item'}->{'Name'};

    if ($name) {
      $item->{'name'} = $name->{'value'};
    }
    else {
      if ( exists $item->{'tagSet'}->{'item'}->{'key'}
        && $item->{'tagSet'}->{'item'}->{'key'} eq 'Name' ) {
        $item->{'name'} = $item->{'tagSet'}->{'item'}->{'value'};
      }
    } ## end else [ if ($name) ]

    my $color = $COLORS{$state} // 'red';

    $t->addRow(
      ++$row,
      @{$item}{
        qw{ instanceId name imageId instanceType privateIpAddress launchTime}
      },
      colored( $state, $color )
    );
  } ## end foreach my $item (@data)

  print $t;

  exit;
} ## end sub main

1;
