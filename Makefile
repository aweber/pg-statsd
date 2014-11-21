EXTENSION  = statsd

EXTVERSION   = '0.1.3'

#EXTVERSION   = $(shell grep default_version $(EXTENSION).control | \
#               sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")

DATA         = $(filter-out $(wildcard sql/*--*.sql),$(wildcard sql/*.sql))
DOCS         = $(wildcard doc/*.*)
MODULE_big   = $(patsubst src/%.c,%,$(wildcard src/*.c))
OBJS         = src/pg_statsd.o
PG_CONFIG    = pg_config

all: sql/$(EXTENSION)--$(EXTVERSION).sql

sql/$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql
# strip first two lines (BEGIN, CREATE SCHEMA) and last line (COMMIT).
	sed '1,2d;$$d' $< > $@

PG91         = $(shell $(PG_CONFIG) --version | grep -qE " 8\.| 9\.0" && echo no || echo yes)

ifeq ($(PG91),yes)
all: sql/$(EXTENSION)--$(EXTVERSION).sql

sql/$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql
# strip first two lines (BEGIN, CREATE SCHEMA) and last line (COMMIT).
	sed '1,2d;$$d' $< > $@

DATA = $(filter-out sql/$(EXTENSION)--$(EXTVERSION).sql, $(wildcard sql/*--*.sql))
EXTRA_CLEAN = sql/$(EXTENSION)--$(EXTVERSION).sql
endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
