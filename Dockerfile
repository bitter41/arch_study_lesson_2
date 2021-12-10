FROM perl

RUN cpanm install Test::Spec

COPY . /usr/src/calc
WORKDIR /usr/src/calc
CMD [ "perl", "./calc.pl" ]
