#!/usr/bin/perl

use strict;
use warnings;

use Amazon::EC2;
use Data::Dumper;
use Term::ANSIColor;
use Text::ASCIITable;
use Furl;
 
my $ec2 = new Amazon::EC2({debug => 0, user_agent => new Furl});

my $result = eval {
  $ec2->DescribeInstances;
};

if ( $@ && ref($@) =~/API::Error/ ) {
  print Dumper([ $@->get_response, $@->get_error ])
}
elsif ($@) {
  die $@;
}

# print STDERR Dumper [ $result ];

my $t = new Text::ASCIITable({headingText => 'EC2 Instances', allowANSI => 1});
$t->setCols('#', 'instanceId', 'name', 'imageId', 'instanceType', 'privateIpAddress', 'launchTime', 'instanceState');

my @data;

foreach my $item (@{$result->{reservationSet}->{item}}) {
  push @data, $item->{instancesSet}->{item};
}

# sort by state (running)
@data = sort { $b->{instanceState}->{name} eq 'running' ? 1 : -1 } @data;

my $row = 0;

foreach my $item (@data) {
  my $state = $item->{instanceState}->{name};

  my $name = $item->{tagSet}->{item}->{Name};
  if ( $name ) {
    $item->{name} = $name->{value};
  }
  else {
    if ( exists $item->{tagSet}->{tagSet}->{item}->{key} && $item->{tagSet}->{item}->{key} eq 'Name' ) {
      $item->{name} = $item->{tagSet}->{item}->{value};
    }
  }
  
  my $color;
  
  for ("$state") {
    
    /running/ && do {
      $color = "green";
      last;
      };
      
    /terminated/ && do {
      $color = "red";
      last;
    };
    
    /stopped/ && do {
      $color = "magenta";
      last;
    };
    
    /pending/ && do {
      $color = "yellow";
      last;
    };
  }

  $t->addRow(++$row, @{$item}{qw/instanceId name imageId instanceType privateIpAddress launchTime/}, colored($state, $color));
}

print $t;

