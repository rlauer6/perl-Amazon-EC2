#!/usr/bin/perl

use strict;
use warnings;

use Amazon::EC2;
use Data::Dumper;
use Term::ANSIColor;
use Text::ASCIITable;
 
my $ec2 = new Amazon::EC2({debug => 0});

my $result = eval {
  $ec2->DescribeInstances;
};

if ( $@ && ref($@) =~/API::Error/ ) {
  print Dumper([ $@->get_response, $@->get_error ])
}
elsif ($@) {
  die $@;
}

my $t = new Text::ASCIITable({headingText => 'EC2 Instances', allowANSI => 1});
$t->setCols('instanceId', 'imageId', 'instanceType', 'privateIpAddress', 'launchTime', 'instanceState');

my @data;

foreach my $item (@{$result->{reservationSet}->{item}}) {
  push @data, $item->{instancesSet}->{item};
}

# sort by state (running)
@data = sort { $b->{instanceState}->{name} eq 'running' ? 1 : -1 } @data;

foreach my $item (@data) {
  my $state = $item->{instanceState}->{name};
  $t->addRow(@{$item}{qw/instanceId imageId instanceType privateIpAddress launchTime/}, $state eq 'running' ? colored($state, 'green') : colored($state, 'red'));
}

print $t;

