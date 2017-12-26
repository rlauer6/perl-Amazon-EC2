
# README

This is the README file for the `perl-Amazon-EC2` project...

# Description

Perl interface to the EC2 API - _this is a work-in-progress_

# Example

```
#!/usr/bin/perl

use strict;
use warnings;

use Amazon::EC2;
use Data::Dumper;

my $ec2 = new Amazon::EC2({debug => 0});
my $filter = [ {Name => 'instance-id', Value => 'i-0b91d8e165cf2f41b'} ];

my $result = $ec2->DescribeInstances(Filter => $filter);
print Dumper $result;
```

# Author

Rob Lauer  <rlauer6@comcast.net>
