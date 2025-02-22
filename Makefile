-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

export README_LINT ?= $(TMP)/README.md
export README_FILE ?= README.md
export README_YAML ?= README.yaml
export README_TEMPLATE_FILE ?= ./templates/README.md.gotmpl
export README_TEMPLATE_YAML := README.yaml
# export README_TEMPLATE_YAML := $(if $(findstring http,$(README_YAML)),$(README_YAML),$(BUILD_HARNESS_PATH)/templates/$(README_YAML))
export README_INCLUDES ?= $(file://$(shell pwd)/?type=text/plain)

## Alias for readme/build
readme: readme/build
	@exit 0

readme/deps: packages/install/gomplate
	@exit 0

## Create basic minimalistic .README.md template file
readme/init:
	@if [ -f $(README_YAML) ]; then \
	  echo "$(README_YAML) already exists!"; \
	else \
	  cp $(README_TEMPLATE_YAML) $(README_YAML) ; \
	  echo "$(README_YAML) created!"; \
	fi;

## Verify the `README.md` is up to date
readme/lint:
	@$(SELF) readme/build README_FILE=$(README_LINT) >/dev/null
	@diff -ruN $(README_LINT) $(README_FILE)
	@rm -f $(README_LINT)

## Create README.md by building it from README.yaml
readme/build: $(README_DEPS)
	@gomplate --file $(README_TEMPLATE_FILE) \
		--out $(README_FILE) 
	@echo "Generated $(README_FILE) from $(README_TEMPLATE_FILE) using data from $(README_TEMPLATE_YAML)"

push: 
	@echo Pushing to remote repoistory
	${CMD} git add .
		${CMD} git commit -m "Gitlab README commit" 
			${CMD} git push -f

docs: docs/build
	@exit 0

docs/build:
	@echo Generating terraform-docs Markdown tables
	${CMD} terraform-docs markdown . --sort-by-required > ./docs/terraform.md