all: build tests run
build:
	docker build -t archstudylesson2 .
tests:
	docker run -it --rm --name archstudylesson2 archstudylesson2 prove ./t
run:
	docker run -it --rm --name archstudylesson2 archstudylesson2
