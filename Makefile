# ANSI escape codes
GREEN=\033[0;32m
RESET=\033[0m

setup:
	@echo "Please ensure you have the following tools installed and configured:"
	@echo "  - python"
	@echo "  - pyenv"
	@echo "  - poetry >= 1.6.1"
	@echo ""

	@command -v python >/dev/null 2>&1 || { echo >&2 "Python is not installed. Exiting."; exit 1; }
	@command -v pyenv >/dev/null 2>&1 || { echo >&2 "pyenv is not installed. Exiting."; exit 1; }
	@if ! command -v poetry >/dev/null 2>&1; then \
		echo >&2 "Poetry is not installed. Exiting."; exit 1; \
	else \
		POETRY_VERSION=$$(poetry --version | cut -d' ' -f3); \
		REQUIRED_VERSION="1.6.1"; \
		if [ "$$(echo -e "$$POETRY_VERSION\n$$REQUIRED_VERSION" | sort -V | head -n1)" != "$$REQUIRED_VERSION" ]; then \
			echo >&2 "Poetry version $$POETRY_VERSION is less than required version $$REQUIRED_VERSION. Please upgrade it."; exit 1; \
		fi \
	fi

	@PYTHON_VERSION=$$(cat .python-version); \
	echo "Using Python version $$PYTHON_VERSION"; \
	pyenv install --skip-existing $$PYTHON_VERSION; \
	pyenv local $$PYTHON_VERSION; \
	which python; \
	python --version;

	curl -sSL https://install.python-poetry.org | python -; \
	poetry --version; \
	poetry config virtualenvs.in-project true --local; \
	poetry env use python $$PYTHON_VERSION; \
	poetry install;

	@if [ ! -d ".git" ]; then \
		git init > /dev/null; \
	fi

	. .venv/bin/activate;
	.venv/bin/pre-commit install;

clean:
	-@if command -v deactivate &> /dev/null; then \
		bash -c "source deactivate" || true; \
	fi
	rm -rf .venv
	rm -rf poetry.lock
	find . -name ".pytest_cache" -type d -exec rm -rf {} +
	find . -name ".mypy_cache" -type d -exec rm -rf {} +
	find . -name ".ruff_cache" -type d -exec rm -rf {} +

test:
	.venv/bin/pre-commit run --all-files
	poetry update
	poetry build
	poetry install --only-root
	pytest tests --cov=src  --cov-report html --cov-report term

deploy_dev:
	.venv/bin/pre-commit run --all-files
	poetry update
	poetry build

	@PROFILE_NAME="REVO"; \
	output=$$(databricks auth env --profile "$$PROFILE_NAME" 2>&1); \
	if [[ $$output == *"Error: resolve:"* ]]; then \
		databricks configure --profile "$$PROFILE_NAME"; \
	else \
		databricks bundle deploy --profile "$$PROFILE_NAME"; \
	fi

destroy_dev:
	@PROFILE_NAME="REVO"; \
	output=$$(databricks auth env --profile "$$PROFILE_NAME" 2>&1); \
	if [[ $$output == *"Error: resolve:"* ]]; then \
		databricks configure --profile "$$PROFILE_NAME"; \
	else \
		databricks bundle destroy --profile "$$PROFILE_NAME"; \
	fi

deploy_prod:
	.venv/bin/pre-commit run --all-files
	poetry update
	poetry build

	@PROFILE_NAME="REVO"; \
	output=$$(databricks auth env --profile "$$PROFILE_NAME" 2>&1); \
	if [[ $$output == *"Error: resolve:"* ]]; then \
		databricks configure --profile "$$PROFILE_NAME"; \
	else \
		databricks bundle deploy --profile "$$PROFILE_NAME" --target prod; \
	fi

destroy_prod:
	@PROFILE_NAME="REVO"; \
	output=$$(databricks auth env --profile "$$PROFILE_NAME" 2>&1); \
	if [[ $$output == *"Error: resolve:"* ]]; then \
		databricks configure --profile "$$PROFILE_NAME"; \
	else \
		databricks bundle destroy --profile "$$PROFILE_NAME" --target prod; \
	fi

# Create a repository in RevoData's GitHub, and adds a remote to the local git repo
repo:
	@printf "$(GREEN)Creating repository in RevoData's GitHub...$(RESET)\n"
	@PROJECT_NAME=$$(grep 'name =' pyproject.toml | awk -F'"' '{print $$2}'); \
	REPO_DESCRIPTION=$$(grep 'description =' pyproject.toml | awk -F'"' '{print $$2}'); \
	if ! gh repo view revodatanl/$$PROJECT_NAME > /dev/null 2>&1; then \
		gh repo create revodatanl/$$PROJECT_NAME -y --private -d "$$REPO_DESCRIPTION" > /dev/null 2>&1; \
		(git remote | grep origin || git remote add origin git@github.com:revodatanl/$$PROJECT_NAME.git) > /dev/null 2>&1; \
		printf "Repository created at revodatanl/$$PROJECT_NAME...$(RESET)\n"; \
		printf "$(GREEN)Publishing project...$(RESET)\n"; \
		printf "Repository published.\n"; \
	else \
		printf "Repository revodatanl/$$PROJECT_NAME already exists.\n"; \
	fi

# Add custom RevoData modules to the project
module:
	@echo "Select the module to deploy:"
	@echo "1) DLT"
	@echo "2) Azure DevOps"
	@echo "3) GitLab"
	@echo "4) VSCode settings"
	@read -p "Enter the number of the module you want to deploy: " choice; \
	case $$choice in \
		1) $(MAKE) module_dlt;; \
		2) $(MAKE) module_azure-devops;; \
		3) $(MAKE) module_gitlab;; \
		4) $(MAKE) module_vscode;; \
		*) echo "Invalid choice. Exiting."; exit 1;; \
	esac

module_dlt:
	@{ \
	set -e; \
	trap 'if [ -f databricks.yml.bak ]; then mv databricks.yml.bak databricks.yml; fi' EXIT; \
	if [ -f databricks.yml ]; then mv databricks.yml databricks.yml.bak; fi; \
	if ! databricks bundle init https://github.com/revodatanl/revo-asset-bundle-templates --template-dir modules/dlt 2>&1; then \
		echo "Exiting." >&2; \
	fi; \
	}

module_azure-devops:
	@{ \
	set -e; \
	trap 'if [ -f databricks.yml.bak ]; then mv databricks.yml.bak databricks.yml; fi' EXIT; \
	if [ -f databricks.yml ]; then mv databricks.yml databricks.yml.bak; fi; \
	if ! databricks bundle init https://github.com/revodatanl/revo-asset-bundle-templates --template-dir modules/azure-devops 2>&1; then \
		echo "Exiting." >&2; \
	fi; \
	}

module_gitlab:
	@{ \
	set -e; \
	trap 'if [ -f databricks.yml.bak ]; then mv databricks.yml.bak databricks.yml; fi' EXIT; \
	if [ -f databricks.yml ]; then mv databricks.yml databricks.yml.bak; fi; \
	if ! databricks bundle init https://github.com/revodatanl/revo-asset-bundle-templates --template-dir modules/gitlab 2>&1; then \
		echo "Exiting." >&2; \
	fi; \
	}

module_vscode:
	@{ \
	set -e; \
	trap 'if [ -f databricks.yml.bak ]; then mv databricks.yml.bak databricks.yml; fi' EXIT; \
	if [ -f databricks.yml ]; then mv databricks.yml databricks.yml.bak; fi; \
	if ! databricks bundle init https://github.com/revodatanl/revo-asset-bundle-templates --template-dir modules/vscode 2>&1; then \
		echo "Exiting." >&2; \
	fi; \
	}
