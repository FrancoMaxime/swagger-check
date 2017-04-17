# Makefile for building releases of swagger-conformance.

# Source directories.
PKGSOURCEDIR = swaggerconformance

# General documentation directories.
DOCSSOURCEDIR = docs/source
SPHINXAPIOUT = $(DOCSSOURCEDIR)/modules
DOCSBUILDDIR = docs/build
DOCSHTMLDIR = $(DOCSBUILDDIR)/html
# Sphinx documentation commands.
SPHINXBUILDOPTS = -E -W
SPHINXBUILD = sphinx-build
SPHINXBUILDTARGET = html
SPHINXAPIDOC = sphinx-apidoc
SPHINXAPIDOCOPTS = -e -f -T
# Pandoc documentation commands.
PANDOC = pandoc

# Python commands.
PYTHONCMD = python3
PYTHONUTDIR = tests
PYTHONUTOPTS = -v -s $(PYTHONUTDIR) -t . -p "test_*.py"
PYCOVERAGECMD = coverage

# Package building values.
DISTSDIR = dist

# Put it first so that "make" without argument is like "make help".
help:
	@echo "Available targets:"
	@echo "    help"
	@echo "        Print this message."
	@echo "    test"
	@echo "        Run all tests."
	@echo "    test_coverage"
	@echo "        Run all tests with code coverage enabled."
	@echo "    docs"
	@echo "        Generate all documentation."
	@echo "    package"
	@echo "        Package up ready for upload to PyPI."
	@echo "    all"
	@echo "        Run all tests and builds, but don't upload the results."
	@echo "    docs_bundle"
	@echo "        Bundle up documentation ready for manual upload to PyPI."
	@echo "    package_upload"
	@echo "        Build and upload the current code to PyPI."

test:
	$(PYTHONCMD) -m unittest discover $(PYTHONUTOPTS)

test_coverage: test
	$(PYCOVERAGECMD) run -m unittest discover $(PYTHONUTOPTS)
	$(PYCOVERAGECMD) report

docs_clean:
	rm -rf "$(DOCSBUILDDIR)"

docs_api:
	rm -rf "$(SPHINXAPIOUT)"
	$(SPHINXAPIDOC) $(SPHINXAPIDOCOPTS) -o "$(SPHINXAPIOUT)" "$(PKGSOURCEDIR)"

docs_md_convert:
	$(PANDOC) readme.md -o $(DOCSSOURCEDIR)/readme.rst
	$(PANDOC) examples/readme.md -o $(DOCSSOURCEDIR)/examples.rst

docs_sphinx: docs_clean docs_api docs_md_convert
	@$(SPHINXBUILD) -M "$(SPHINXBUILDTARGET)" "$(DOCSSOURCEDIR)" \
		"$(DOCSBUILDDIR)" $(SPHINXBUILDOPTS)

docs: docs_sphinx

docs_bundle: docs
	cd $(DOCSHTMLDIR) ; zip -r docs.zip .
	@echo "Docs are bundled up in $(DOCSHTMLDIR)/docs.zip"

package: test
	rm -rf "$(DISTSDIR)"
	$(PYTHONCMD) setup.py sdist bdist_wheel

package_upload: package
	twine register dist/swagger_conformance-*-py3-none-any.whl
	twine upload dist/*

all: docs test_coverage package

.PHONY: help test docs_clean docs_api docs_md_convert docs_sphinx docs \
	docs_bundle package package_upload all
