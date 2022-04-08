generate-doc:
	terraform-docs markdown table --output-file README.md --output-mode inject .
