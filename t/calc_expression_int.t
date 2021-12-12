use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe 'calc_expression: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[EXCEPTION] ' => sub {
        it 'should confess if missed close bracket' => sub {
            trap { Calc::calc_expression( '(1 + 2 * 4 + 3' ) };

            like( $trap->die, qr/Seems you missed close bracket/ ) or diag( $trap->die );
        };

        it 'should confess if missed close bracket' => sub {
            trap { Calc::calc_expression( '((1 + 2) * 4 + 3' ) };

            like( $trap->die, qr/Seems you missed close bracket/ ) or diag( $trap->die );
        };

        it 'should confess if wrong order of brackets' => sub {
            trap { Calc::calc_expression( '(1 (+ 2() * 4 + 3' ) };

            like( $trap->die, qr/Seems you missed close bracket/ ) or diag( $trap->die );
        };

        it 'should confess if wrong direction of brackets' => sub {
            trap { Calc::calc_expression( '(1 + 2) * )4 + 3(' ) };

            like( $trap->die, qr/Seems you missed open bracket/ ) or diag( $trap->die );
        };

        it 'should confess if missed open bracket' => sub {
            trap { Calc::calc_expression( '(1 + 2) * )4 + 3' ) };

            like( $trap->die, qr/Seems you missed open bracket/ ) or diag( $trap->die );
        };

    };

    describe '[SUCCESS] ' => sub {

        it 'calc for: (1 + 2) * 4 + 3 = 15' => sub {
            is Calc::calc_expression( '(1 + 2) * 4 + 3' ), 15;
        };

        it 'calc for: 1 + 2 * 4 + 3 = 12' => sub {
            is Calc::calc_expression( '1 + 2 * 4 + 3' ), 12;
        };

        it 'calc for: ((1 + 2) * 4 + 6) / 3 = 12' => sub {
            is Calc::calc_expression( '((1 + 2) * 4 + 6) / 3' ), 6;
        };

        it 'calc for: (1+2) * 14 /6 +2 * (3+2) = ??' => sub {
            is Calc::calc_expression( '(1+2) * 14 /6 +2 * (3+2)' ), 17;
        };

    };
};

runtests();
