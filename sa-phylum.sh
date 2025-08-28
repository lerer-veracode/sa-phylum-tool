#!/bin/bash

# ==============================================================================
# Script: sa-phylum.sh
# Description: Configures package managers to use Phylum's secure registry firewall.
# Author: Gemini
# Version: 1.0
# ==============================================================================

# --- Default Configuration ---
MODE=""
ECOSYSTEM="npm" # Default ecosystem if not specified
CONFIG_FILE="$HOME/.veracode/phylum"

# --- Help Function ---
# Displays detailed help information for the script.
show_help() {
  cat << EOF
Usage: ./sa-phylum.sh -mode <demo|off> [options]

This script configures your package manager to either use the Phylum package firewall
(demo mode) or revert to the default public registry (off mode).

REQUIRED ARGUMENTS:
  -mode, --m <demo|off>   Specify the operational mode.
                            - 'demo': Route package manager traffic through the Phylum firewall.
                            - 'off':  Restore the default public registry settings.

OPTIONAL ARGUMENTS:
  -e, --ecosystem <npm|pypi|maven>
                          Specify the package ecosystem.
                          (Default: npm). pypi and maven are not yet supported.
  -h, --help              Display this help message and exit.

CONFIGURATION:
The script requires two variables: FIREWALL_NAME and PHYLUM_API_KEY.
It will look for these variables in the following order:

1. A configuration file located at: $CONFIG_FILE
   The file should contain:
   FIREWALL_NAME="your-firewall-name"
   PHYLUM_API_KEY="your-phylum-api-key"

2. Environment variables.
   You can set them using:
   export FIREWALL_NAME="your-firewall-name"
   export PHYLUM_API_KEY="your-phylum-api-key"

If these variables are not found, the script will exit with an error in 'demo' mode.

EXAMPLES:
  # Enable Phylum firewall for npm
  ./sa-phylum.sh -mode demo

  # Disable Phylum firewall for npm
  ./sa-phylum.sh -mode off

  # Explicitly specify the npm ecosystem (demo mode)
  ./sa-phylum.sh -mode demo -e npm
EOF
}

# --- Argument Parsing ---
# Loops through command-line arguments and assigns them to variables.
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -m|--mode)
      MODE="$2"
      shift # past argument
      shift # past value
      ;;
    -e|--ecosystem)
      ECOSYSTEM="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)    # unknown option
      echo "Error: Unknown option '$1'"
      show_help
      exit 1
      ;;
  esac
done

# --- Configuration Loading ---
# Load variables from config file if it exists, otherwise check environment variables.
if [[ -f "$CONFIG_FILE" ]]; then
    # Source the file to load the variables
    # Use set -a to export the variables so they are available in the script's environment
    set -a
    source "$CONFIG_FILE"
    set +a
    echo "Info: Loaded configuration from $CONFIG_FILE"
fi

# Fallback to environment variables if not set in the file
FIREWALL_NAME=${FIREWALL_NAME:-}
PHYLUM_API_KEY=${PHYLUM_API_KEY:-}


# --- Input Validation ---
# Check if the mode parameter was provided.
if [[ -z "$MODE" ]]; then
  echo "Error: The -mode parameter is required."
  show_help
  exit 1
fi

# Check if the mode has a valid value.
if [[ "$MODE" != "demo" && "$MODE" != "off" ]]; then
  echo "Error: Invalid value for -mode. Must be 'demo' or 'off'."
  show_help
  exit 1
fi

# If in demo mode, ensure credentials are set.
if [[ "$MODE" == "demo" ]]; then
  if [[ -z "$FIREWALL_NAME" || -z "$PHYLUM_API_KEY" ]]; then
    echo "Error: FIREWALL_NAME and PHYLUM_API_KEY must be set for 'demo' mode."
    echo "Please set them in $CONFIG_FILE or as environment variables."
    exit 1
  fi
fi

# --- Main Logic ---
# Convert ecosystem to lowercase for case-insensitive comparison.
ECOSYSTEM_LOWER=$(echo "$ECOSYSTEM" | tr '[:upper:]' '[:lower:]')

case $ECOSYSTEM_LOWER in
  npm)
    if [[ "$MODE" == "demo" ]]; then
      echo "Info: Configuring npm to use Phylum firewall..."
      npm config set registry "https://"$FIREWALL_NAME":"$PHYLUM_API_KEY"@npm.phylum.io/"
      echo "Success: npm registry set to Phylum."
    elif [[ "$MODE" == "off" ]]; then
      echo "Info: Reverting npm to the default registry..."
      npm config set registry "https://registry.npmjs.org/"
      echo "Success: npm registry has been reset."
    fi
    ;;
  pypi|maven)
    echo "Info: The '$ECOSYSTEM' ecosystem is not yet supported."
    exit 0
    ;;
  *)
    echo "Error: Invalid ecosystem specified: '$ECOSYSTEM'."
    echo "Allowed values are 'npm', 'pypi', or 'maven'."
    exit 1
    ;;
esac

exit 0
