all: build test tests
build:
	docker build -t archstudylesson2 .
tests:
	docker run -it --rm --name archstudylesson2 archstudylesson2 prove ./t
run:
	docker run -it --rm --name archstudylesson2 archstudylesson2
test:
	docker run -it --rm --name archstudylesson2 archstudylesson2 perl ./t/__is_number.t
	docker run -it --rm --name archstudylesson2 archstudylesson2 perl ./t/convert_to_reverse_polish_notation_int.t
