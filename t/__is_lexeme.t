use Data::Dumper;
use Test::Spec;
use Test::Spec::Mocks;
use lib qw( ./lib ../lib );

describe '__is_lexeme: ' => sub {

    it 'should include module Calc.pm successfuly' => sub {
        use_ok('Calc');
    };

    describe '[BRANCH] ' => sub {

        it 'should return 0 for wrong lexeme with undef arg' => sub {
            ok ! Calc::__is_lexeme( undef );
        };

        it 'should return 0 for wrong lexeme with string length > 1' => sub {
            ok ! Calc::__is_lexeme( '++++' );
        };

        it 'should return 0 for wrong lexeme with empty string' => sub {
            ok ! Calc::__is_lexeme( '' );
        };

        it 'should return 1 for right numeric lexeme' => sub {
            ok Calc::__is_lexeme( '4' );
        };

        it 'should return 1 for right numeric lexeme' => sub {
            ok Calc::__is_lexeme( '4444' );
        };

        it 'should return 1 for right allowed lexeme: (' => sub {
            ok Calc::__is_lexeme( '(' );
        };

        it 'should return 1 for right allowed lexeme: )' => sub {
            ok Calc::__is_lexeme( ')' );
        };

        it 'should return 1 for right allowed lexeme: *' => sub {
            ok Calc::__is_lexeme( '*' );
        };

        it 'should return 1 for right allowed lexeme: /' => sub {
            ok Calc::__is_lexeme( '/' );
        };

        it 'should return 1 for right allowed lexeme: +' => sub {
            ok Calc::__is_lexeme( '+' );
        };

        it 'should return 1 for right allowed lexeme: -' => sub {
            ok Calc::__is_lexeme( '-' );
        };

        it 'should return 1 for right allowed lexeme: <space>' => sub {
            ok Calc::__is_lexeme( ' ' );
        };

        it 'should return 0 for not allowed lexeme: x' => sub {
            ok !Calc::__is_lexeme( 'x' );
        };
    };
};

runtests();
