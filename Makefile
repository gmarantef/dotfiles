TESTS_DIR := tests/integration

.PHONY: test test-ubuntu test-fedora test-arch test-fast test-build

## Corre todos los tests en todas las distros (lento — incluye brew)
test:
	@bash $(TESTS_DIR)/run_tests.sh

## Tests sólo para Ubuntu
test-ubuntu:
	@bash $(TESTS_DIR)/run_tests.sh ubuntu

## Tests sólo para Fedora
test-fedora:
	@bash $(TESTS_DIR)/run_tests.sh fedora

## Tests sólo para Arch
test-arch:
	@bash $(TESTS_DIR)/run_tests.sh arch

## Tests rápidos: features sin dependencia de brew (shell, cloud, ai)
## Útil para validar cambios puntuales sin esperar la instalación de Homebrew
test-fast:
	@for distro in ubuntu fedora arch; do \
	  for feature in shell cloud ai; do \
	    bash $(TESTS_DIR)/run_tests.sh $$distro $$feature; \
	  done; \
	done

## Pre-construye todas las imágenes Docker sin correr tests
test-build:
	@for distro in ubuntu fedora arch; do \
	  docker build \
	    -f $(TESTS_DIR)/dockerfiles/Dockerfile.$$distro \
	    -t bootstrap-test-$$distro \
	    . ; \
	done
