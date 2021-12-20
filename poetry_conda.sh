#!/bin/sh
if [[ $1 == "install" ]]; then
    echo "Also perform poetry install"
    # The following command installs poetry via its official installer
    curl -sSL https://install.python-poetry.org | python3 -
fi

# generate env file in project's git
conda env export --from-history | grep -v "^prefix" > environment.yml

