# iced-bar - FreeBSD make(1); also works with GNU make.
#   make            build
#   make test       tests against ./iced-bar (scratch dir, no root)
#   make test-sh    the same tests against ../scripts/iced-bar.sh
#   make install    to ~/.local/bin (PREFIX=/usr/local as root)

PROG=	iced-bar
CC?=	cc
CFLAGS=	-std=c11 -O2 -Wall -Wextra -Wpedantic -Werror
PREFIX?=	${HOME}/.local

all: ${PROG}

${PROG}: iced-bar.c
	${CC} ${CFLAGS} -o ${PROG} iced-bar.c

test: ${PROG}
	sh ./test.sh ./${PROG}

test-sh:
	sh ./test.sh ../scripts/iced-bar.sh 7

install: ${PROG}
	install -d ${PREFIX}/bin
	install -m 0755 ${PROG} ${PREFIX}/bin/${PROG}

clean:
	rm -f ${PROG}

.PHONY: all test test-sh install clean
