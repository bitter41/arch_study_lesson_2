use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe '__unload_stack_to_open_bracket: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[EXCEPTION] ' => sub {
        it 'should confess if arg is not array' => sub {
            trap { Calc::__unload_stack_to_open_bracket( {} ) };

            like( $trap->die, qr/Argument must be array ref/ ) or diag( $trap->die );
        };

        it 'should confess if not found open bracket in stack' => sub {
            my @stack = qw/ 1 2 3 4 5 6 /;

            trap { Calc::__unload_stack_to_open_bracket( \@stack ) };

            like( $trap->die, qr/Seems you missed open bracket/ ) or diag( $trap->die );
        };

    };

    describe '[BRANCH] ' => sub {

        it 'should unload part of stack to open bracket' => sub {
            my @stack = qw/ 1 2 3 ( 4 5 6 /;

            my @result = Calc::__unload_stack_to_open_bracket( \@stack );

            cmp_deeply \@result, [qw( 6 5 4 )];
            cmp_deeply \@stack, [qw/ 1 2 3 /];
        };

    };
};

runtests();
