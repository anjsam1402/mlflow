#!/usr/bin/env bash

# Executes a subset of mlflow tests that is supported with fewer dependencies than the core mlflow package.
# Tests include most client interactions and compatibility points with the mlflow plugins around tracking, projects, models, deployments, and the cli.

# The SQL alchemy store's dependencies are added for a base client/store that can be tested against.
# A different example client/store with a minimal dependency footprint could also work for this purpose.

set -x
# Set err=1 if any commands exit with non-zero status as described in
# https://stackoverflow.com/a/42219754
err=0
trap 'err=1' ERR
export MLFLOW_SKINNY='true'

pytest tests/test_skinny_client_omits_sql_libs.py

# After verifying skinny client does not include store specific requirements,
# we are installing sqlalchemy store requirements as our example store for the test suite.
# SQL Alchemy serves as a simple, fully featured option to test skinny client store scenarios.
python -m pip install sqlalchemy alembic sqlparse

# Given the example store does not delete dependencies, we verify non store related dependencies
# after the example store setup. This verifies both the example store and skinny client do not add
# unintended libraries.
pytest tests/test_skinny_client_omits_data_science_libs.py

pytest tests/test_runs.py
pytest tests/tracking/test_client.py
pytest tests/tracking/test_tracking.py
pytest tests/projects/test_projects.py
pytest tests/deployments/test_cli.py
pytest tests/deployments/test_deployments.py
pytest tests/projects/test_projects_cli.py
pytest tests/utils/test_requirements_utils.py::test_infer_requirements_excludes_mlflow

test $err = 0
