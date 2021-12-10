use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe 'convert_to_reverse_polish_notation: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[SUCCESS] ' => sub {

        it 'base check result' => sub {
            is Calc::convert_to_reverse_polish_notation( '(1 + 2) * 4 + 3' ), '1 2 + 4 * 3 + ';
        };

    };
};

runtests();
