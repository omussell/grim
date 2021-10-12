#!/bin/sh

isort --check --diff src
black --check --diff src
mypy src
