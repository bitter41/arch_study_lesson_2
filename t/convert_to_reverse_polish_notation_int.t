use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe 'convert_to_reverse_polish_notation: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[EXCEPTION] ' => sub {
        it 'should confess if missed close bracket' => sub {
            trap { Calc::convert_to_reverse_polish_notation( '(1 + 2 * 4 + 3' ) };

            like( $trap->die, qr/Seems you missed close bracket/ ) or diag( $trap->die );
        };

        it 'should confess if missed close bracket' => sub {
            trap { Calc::convert_to_reverse_polish_notation( '((1 + 2) * 4 + 3' ) };

            like( $trap->die, qr/Seems you missed close bracket/ ) or diag( $trap->die );
        };

        it 'should confess if wrong order of brackets' => sub {
            trap { Calc::convert_to_reverse_polish_notation( '(1 (+ 2() * 4 + 3' ) };

            like( $trap->die, qr/Seems you missed close bracket/ ) or diag( $trap->die );
        };

        it 'should confess if wrong direction of brackets' => sub {
            trap { Calc::convert_to_reverse_polish_notation( '(1 + 2) * )4 + 3(' ) };

            like( $trap->die, qr/Seems you missed open bracket/ ) or diag( $trap->die );
        };

    };

    describe '[SUCCESS] ' => sub {

        it 'check for: (1 + 2) * 4 + 3' => sub {
            is Calc::convert_to_reverse_polish_notation( '(1 + 2) * 4 + 3' ), '1 2 + 4 * 3 + ';
        };

        #it 'check for bracket maniac: (1) (+) (2) (*) (4) (+) (3)' => sub {
        #    is Calc::convert_to_reverse_polish_notation( '(1) (+) (2) (*) (4) (+) (3)' ), '1 2 4 * + 3 + ';
        #};

        it 'check for bracket maniac: 1 + 2 * 4 + 3' => sub {
            is Calc::convert_to_reverse_polish_notation( '1 + 2 * 4 + 3' ), '1 2 4 * + 3 + ';
        };

    };
};

runtests();
