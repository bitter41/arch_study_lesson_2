use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe '__is_number: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[BRANCH] ' => sub {

        it 'should return 0 for wrong lexeme with undef arg' => sub {
            ok ! Calc::__is_number( undef );
        };

        it 'should return 2 for lexeme with more then one digit' => sub {
            ok Calc::__is_number( '444' );
        };

        it 'should return 0 for wrong lexeme with empty string' => sub {
            ok ! Calc::__is_number( '' );
        };

        it 'should return 1 for right numeric lexeme' => sub {
            ok Calc::__is_lexeme( '4' );
        };

        it 'should return 0 for not numeric lexeme: x' => sub {
            ok !Calc::__is_lexeme( 'x' );
        };
    };
};

runtests();
