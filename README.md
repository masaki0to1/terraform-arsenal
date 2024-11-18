# Enterprise-Grade Terraform Modules Repository

A comprehensive collection of production-ready Terraform modules designed for enterprise use cases, providing reusable infrastructure components with best practices and security considerations built-in.

## Prerequisites
- Python 3.11.0 or later
- jq
- pyenv

## Development Environment Setup
Please follow these steps after cloning the repository.
These instructions are for macOS environments.

```bash
# Install required tools
brew install jq 
brew install pyenv

# Verify installations
jq --version
pyenv --version

# Add the following to ~/.zshrc or ~/.bash_profile
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Reload shell configuration
source ~/.zshrc # or ~/.bash_profile

# Install required Python version
pyenv install 3.11.0

# Set the Python version for the project
pyenv local 3.11.0

# Create a virtual environment
python -m venv .venv

# Activate the virtual environment
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Module Development
When adding new modules, you can automatically generate:
- Module documentation
- Architecture diagrams
- Naming convention validation
- Security compliance checks

Run the following command from the repository root:

```bash
# Generate documentation and run validations
cd tools
python -m terraform_docs.main --modules-path ../modules
```