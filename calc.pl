#!/usr/bin/env perl

use lib './lib';
use Data::Dumper;
use Calc;
use strict;
use warnings;

use constant DEBUG_STATUS_FOR_TOGGLE_DICT => {
    0 => 'Enable',
    1 => 'Disable',
};

my $debug_mode = 0;
print "###################################\n";

while (1) {
    my $debug_status_for_tiggle = DEBUG_STATUS_FOR_TOGGLE_DICT->{$debug_mode};
    print <<THEEND;
###################################
Commands:
    /debug: $debug_status_for_tiggle debug mode
    /exit
-----------------------------------

THEEND
    print "Enter expression or command: ";
    my $expression = <STDIN>;
    chomp $expression;

    last if $expression eq '/exit';
    if ($expression eq '/debug') {
        $debug_mode = $debug_mode ^ 1; # xor / toggle
        next;
    }

    my $expression_in_reverse_polish_notation = eval { Calc::convert_to_reverse_polish_notation( $expression ) };
    unless ($expression_in_reverse_polish_notation) {
        my $error_message = $@;
        print "$error_message\n";
        next;
    }
    print "Expression in rpn: $expression_in_reverse_polish_notation\n";

    my $result = eval { Calc::calc_expression( $expression, { debug_mode => $debug_mode } ) };
    unless ($result) {
        my $error_message = $@;
        print "$error_message\n";
        next;
    }

    print "Result of expression: $result\n\n\n";
}

#     (1+2) * 14 /6 +2 * (3+2)