# test_bundles

[![python](https://upload.wikimedia.org/wikipedia/commons/1/16/Blue_Python_3.10%2B_Shield_Badge.svg)](https://www.python.org)
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)
[![Checked with mypy](http://www.mypy-lang.org/static/mypy_badge.svg)](http://mypy-lang.org/)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![ci](https://github.com/revodatanl/test_bundles/actions/workflows/ci.yml/badge.svg)](https://github.com/revodatanl/test_bundles/actions/workflows/ci.yml)
[![semantic_release](https://github.com/revodatanl/test_bundles/actions/workflows/semantic_release.yml/badge.svg)](https://github.com/revodatanl/test_bundles/actions/workflows/semantic_release.yml)
[![coverage](https://github.com/revodatanl/test_bundles/blob/main/assets/coverage.svg)](https://github.com/revodatanl/test_bundles/blob/main/assets/coverage.svg)

The `test_bundles` Bundle was generated by using the [RevoData Asset Bundle Template](https://github.com/revodatanl/revo-asset-bundle-templates) version `0.3.0`.

### Pre-requisites

- [Databricks CLI](https://docs.databricks.com/dev-tools/cli/databricks-cli.html) (installed and configured)
- [Git](https://git-scm.com)
- [Poetry](https://python-poetry.org/docs) >= 1.6.1
- [pyenv](https://github.com/pyenv/pyenv)
- [Python](https://www.python.org)

The `test_bundles` Bundle utilizes a `Makefile` to simplify the Databricks Asset Bundle deployment process, although technically this is not a requirement.

## Getting started

To set up a fully configured development environment for this project run the following command:

```bash
make setup
```

This will use [pyenv](https://github.com/pyenv/pyenv) to configure the correct [Python](https://www.python.org/) version specified in the `.python-version` file. Subsequently it will use [Poetry](https://python-poetry.org/docs/) to install the dependencies, set up a virtual environment, activate it, and install the pre-commit hooks. Note that the default project configuration matches Databricks Runtime 14.3 LTS (Python 3.10.12, Apache Spark 3.5.0, and pandas 1.5.3).

![make setup](./assets/make-setup.png)

## RevoData Modules

To add our custom modules to your project, run the following command:

```bash
make module
```

![make module](./assets/make-module.png)

## Create GitHub repository

To create a repository in RevoData's GitHub, and add a remote to the local git repository containing the Bundle, use the following commands:

```bash
make repo
```

This assumes that access to the RevoData GitHub organization is granted and configured.

![make repo](./assets/make-repo.png)

## Development

The following commands are available for development:

```bash
make clean
```

![make clean](./assets/make-clean.png)

This command deactivates the virtual environment, removes the virtual environment and the `poetry.lock` file, and removes any caches.

![make clean](./assets/make-clean.png)

```bash
make test
```

This command runs the tests for the project.

![make test](./assets/make-test.png)

## Deployment

To deploy the Bundle to Databricks with ease, use the following commands:

### `dev` environment

To deploy the Bundle to the (default) `dev` target:

```bash
make deploy_dev
```

This will deploy the Bundle to the Databricks workspace, using the `~/.databrickscfg` profile specified during initialization.

![make deploy_dev](./assets/make-deploy_dev.png)

### `prod` environment

To deploy the Bundle to the `prod` target:

```bash
make deploy_prod
```
## Bundle Destruction

To remove the Bundle from the Databricks workspace, use the following command:

```bash
make destroy_dev # or make destroy_prod
```

![make destroy_dev](./assets/make-destroy_dev.png)
# databricks_bundles
