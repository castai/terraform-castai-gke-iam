generate-doc:
	terraform-docs markdown table --lockfile=false --output-file README.md --output-mode inject .
