#include "factor.h"

CELL cons(CELL car, CELL cdr)
{
	CONS* cons = allot(sizeof(CONS));
	cons->car = car;
	cons->cdr = cdr;
	return tag_cons(cons);
}

void primitive_cons(void)
{
	CELL cdr = dpop();
	CELL car = dpop();
	dpush(cons(car,cdr));
}

void primitive_car(void)
{
	drepl(car(dpeek()));
}

void primitive_cdr(void)
{
	drepl(cdr(dpeek()));
}
