package Calc;

use Data::Dumper;

use constant OPERATOR_LEXEMES_PRIORITY => {
    '*' => 1,
    '/' => 1,
    '+' => 0,
    '-' => 0, 
}; 
use constant OPERATOR_LEXEMES_LIST => ( '+', '-', '*', '/' );
use constant OPEN_BRACKET_LEXEME   => '(';
use constant CLOSE_BRACKET_LEXEME  => ')';
use constant LEXEMES_ALLOW_LIST    => ( 
                                        ' ',
                                        OPEN_BRACKET_LEXEME,
                                        CLOSE_BRACKET_LEXEME
                                      ),
                                      OPERATOR_LEXEMES_LIST;


=head2 C<calc_expression>($expression, $params)

Посчитать результат выражения

=cut

sub calc_expression {
    my ($expression, $params) = @_;

    my $result;

    my @expression_in_reverse_polish_notation_array = __convert_to_reverse_polish_notation($expression);
    my @stack = ();
    print "lexeme\tstack\n" if $params->{debug_mode};
    foreach my $lexeme (@expression_in_reverse_polish_notation_array) {
        if ( __is_number($lexeme) ) {
            __push_to_stack(\@stack, $lexeme);
        }
        elsif ( __is_operator($lexeme) ) {
            my $number_lexeme_right = pop @stack;
            my $number_lexeme_left  = pop @stack;

            my $result_of_operation = eval( "$number_lexeme_left $lexeme $number_lexeme_right" );
            __push_to_stack(\@stack, $result_of_operation);
        }
        print "$lexeme\t" . join(',', @stack) . "\n" if $params->{debug_mode};
    }

    die 'Something wrong with expression, have some unused lexemes in stack: ' . join(',', @stack)
        if scalar @stack > 1;

    return pop @stack;
}

=head2 C<convert_to_reverse_polish_notation>($expression)

Конвертировать выражение в обратную польскую запись

=cut

sub convert_to_reverse_polish_notation {
    my ($expression) = @_;

    my @result_in_rpn_array = __convert_to_reverse_polish_notation($expression);
    
    my $result_in_rpn = join ' ', @result_in_rpn_array;
    #print Dumper(\@result_in_rpn_array, $result_in_rpn);

    return $result_in_rpn;
}

=head2 C<__convert_to_reverse_polish_notation>($expression)

Конвертировать выражение в обратную польскую запись, возвращает массив

=cut

sub __convert_to_reverse_polish_notation {
    my ($expression) = @_;

    my @result_in_rpn_array = ();

    die 'Argument must be string'                     if ref $expression;
    die "Found wrong lexeme in argument: $expression" if __has_any_wrong_lexemes($expression);

    my @stack = ();
    my @expression_array = __split_expression($expression);
    #print Dumper(\@expression_array);
    foreach my $lexeme (@expression_array) {
        next unless __is_lexeme($lexeme);

        if ( __is_number($lexeme) ) {
            push @result_in_rpn_array, $lexeme;
        }
        elsif ( __is_operator($lexeme) ) {
            push @result_in_rpn_array, __unload_operators(\@stack, $lexeme);
            __push_to_stack( \@stack, $lexeme );
        }
        elsif ( __is_open_bracket($lexeme) ) {
            __push_to_stack( \@stack, $lexeme );
        }
        elsif ( __is_close_bracket($lexeme) ) {
            push @result_in_rpn_array, __unload_stack_to_open_bracket( \@stack );
        }
        #print "$lexeme\t" . join('', @stack) . "\t" . $result_in_rpn . "\n";
    }
    push @result_in_rpn_array, __unload_stack( \@stack );

    #print Dumper(\@expression_array);

    return @result_in_rpn_array;
}

=head2 C<__has_any_wrong_lexemes>($expression)

Есть ли в выражении какие нибудь неправильные лексемы?

=cut

sub __has_any_wrong_lexemes {
    my ($expression) = @_; 

    # Вырежем лексемы по списку
    $expression =~ s|\Q$_||g foreach (LEXEMES_ALLOW_LIST);

    # Вырежем числовые лексемы
    $expression =~ s|\d+||g;

    return 0 unless $expression;

    return 1;
}

=head2 C<__is_lexeme>($lexeme)

Является ли переданная строка лексемой?

=cut

sub __is_lexeme {
    my ($lexeme) = @_; 

    $lexeme ||= '';

    return 1 if $lexeme =~ /\d+/;

    return 0 if length($lexeme) != 1;

    foreach my $allow_lexeme (LEXEMES_ALLOW_LIST) {
        return 1 if $lexeme eq $allow_lexeme;
    }

    return 0;
}

=head2 C<__is_number>($lexeme)

Является ли переданная лексема числом?

=cut

sub __is_number {
    my ($lexeme) = @_; 

    $lexeme ||= '';

    return 1 if $lexeme =~ /\d+/;

    return 0;
}

=head2 C<__is_operator>($lexeme)

Является ли переданная лексема оператором?

=cut

sub __is_operator {
    my ($lexeme) = @_; 

    $lexeme ||= '';

    return 0 if length($lexeme) != 1;

    foreach my $allow_lexeme (OPERATOR_LEXEMES_LIST) {
        return 1 if $lexeme eq $allow_lexeme;
    }

    return 0;
}

=head2 C<__is_open_bracket>($lexeme)

Является ли переданная лексема открывающей скобкой?

=cut

sub __is_open_bracket {
    my ($lexeme) = @_; 

    $lexeme ||= '';

    return 0 if length($lexeme) != 1;

    return 1 if $lexeme eq OPEN_BRACKET_LEXEME;

    return 0;
}

=head2 C<__is_close_bracket>($lexeme)

Является ли переданная лексема закрывающей скобкой?

=cut

sub __is_close_bracket {
    my ($lexeme) = @_; 

    $lexeme ||= '';

    return 0 if length($lexeme) != 1;

    return 1 if $lexeme eq CLOSE_BRACKET_LEXEME;

    return 0;
}

=head2 C<__push_to_stack>($stack_ref, $lexeme)

Поместить лексему в стек

=cut

sub __push_to_stack {
    my ( $stack_ref, $lexeme ) = @_;

    die 'Argument must be array ref' if ref $stack_ref ne 'ARRAY';

    push @$stack_ref, $lexeme;
}

=head2 C<__unload_stack_to_open_bracket>($stack_ref)

Выгрузить стек до открывающей скобки, вернув результат в виде строки

=cut

sub __unload_stack_to_open_bracket {
    my ($stack_ref) = @_;

    die 'Argument must be array ref' if ref $stack_ref ne 'ARRAY';

    my @result             = ();
    my $open_bracket_found = 0;
    while (@$stack_ref) {
        my $lexeme = pop @$stack_ref;
        if ($lexeme eq OPEN_BRACKET_LEXEME) {
            $open_bracket_found = 1;
            last;
        };
        push @result, $lexeme;
    }

    die 'Seems you missed open bracket' unless $open_bracket_found;

    return @result;
}

=head2 C<__unload_stack>($stack_ref)

Выгрузить стек, вернув результат в виде строки

=cut

sub __unload_stack {
    my ($stack_ref) = @_;

    die 'Argument must be array ref' if ref $stack_ref ne 'ARRAY';

    my @result = ();
    while (@$stack_ref) {
        my $lexeme = pop @$stack_ref;
        die 'Seems you missed close bracket' if $lexeme eq OPEN_BRACKET_LEXEME;
        push @result, $lexeme;
    }

    return @result;
}

=head2 C<__unload_operators>($stack_ref, $operator_lexeme)

Выгрузить операторы из стека, вернув результат в виде строки

=cut

sub __unload_operators {
    my ($stack_ref, $operator_lexeme) = @_;

    die 'Argument must be array ref'       if ref $stack_ref ne 'ARRAY';
    die 'Argument must by operator lexeme' unless __is_operator($operator_lexeme);

    my @result = ();
    while (@$stack_ref) {
        my $lexeme_from_top = $stack_ref->[-1];
        last unless __is_operator($lexeme_from_top);
        last if OPERATOR_LEXEMES_PRIORITY->{$lexeme_from_top} < OPERATOR_LEXEMES_PRIORITY->{$operator_lexeme};

        push @result, pop @$stack_ref;
    }

    return @result;
}

=head2 C<__split_expression>($expression)

Разбить строку выражение на массив

=cut

sub __split_expression {
    my ($expression) = @_;

    my @result_array = ();

    # Удалим все пробельные символы
    $expression =~s/\s+//g;

    foreach my $lexeme (split //, $expression) {
        my $last_lexeme = $result_array[-1] || '';
        
        if (
            $last_lexeme
            && __is_number($last_lexeme)
            && __is_number($lexeme)
        ) {
            $last_lexeme = pop @result_array;
            $lexeme = $last_lexeme . $lexeme;
        }

        push @result_array, $lexeme;
    }


    return @result_array;
}

1;
