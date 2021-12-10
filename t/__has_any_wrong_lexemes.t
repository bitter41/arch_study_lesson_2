use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe '__has_any_wrong_lexemes: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[SUCCESS] ' => sub {

        it 'correct expression: (1 + 2) * 4 + 3' => sub {
            ok ! Calc::__has_any_wrong_lexemes( '(1 + 2) * 4 + 3' );
        };

        it 'only allow lexemes in expression: () * + - / 1 2 3 4 5 66 77' => sub {
            ok ! Calc::__has_any_wrong_lexemes( '() * + - / 1 2 3 4 5 66 77' );
        };

        it 'has not allowed lexemes in expression: []' => sub {
            ok Calc::__has_any_wrong_lexemes( '[]' );
        };

        it 'has not allowed lexemes in expression: xxx' => sub {
            ok Calc::__has_any_wrong_lexemes( 'xxx' );
        };

    };
};

runtests();
