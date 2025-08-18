.PHONY: all backend stagess admin

all: backend

backend: $(MAKE) -C stagess_backend
stagess: $(MAKE) -C stagess
admin: $(MAKE) -C stagess_admin
