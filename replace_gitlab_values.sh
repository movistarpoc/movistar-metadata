#!/bin/bash
set -e

# ==============================================================================
# Install dependencies
# ==============================================================================
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    apk add --no-cache git
fi

# ==============================================================================
# Global variables
# ==============================================================================
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
CI_FILE=""

# ==============================================================================
# Utility functions
# ==============================================================================
log_section() {
    echo ""
    echo "=== $1 ==="
}

log_error() {
    echo "ERROR: $1"
}

# ==============================================================================
# Core functions
# ==============================================================================
extract_application_id() {
    log_section "Extracting Application ID"

    local nrn=$(echo "$NP_ACTION_CONTEXT" | jq -r '.notification.nrn')
    echo "NRN: $nrn"

    if [ -z "$nrn" ] || [ "$nrn" == "null" ]; then
        log_error "No NRN found in context"
        exit 1
    fi

    APPLICATION_ID=$(echo "$nrn" | sed -n 's/.*application=\([0-9]*\).*/\1/p')
    echo "APPLICATION_ID: $APPLICATION_ID"

    if [ -z "$APPLICATION_ID" ]; then
        log_error "Could not extract application_id from NRN"
        exit 1
    fi
}

fetch_repository_url() {
    log_section "Fetching Repository URL"

    local app_data=$(np application read --id "$APPLICATION_ID" --format json)

    if [ -z "$app_data" ]; then
        log_error "Could not fetch application data"
        exit 1
    fi

    REPO_URL=$(echo "$app_data" | jq -r '.repository_url // .repo_url // .repository // empty')
    echo "REPO_URL: $REPO_URL"

    if [ -z "$REPO_URL" ]; then
        log_error "No repository URL found in application data"
        exit 1
    fi
}

clone_repository() {
    log_section "Cloning Repository"

    cd "$SCRIPT_DIR" && cd ..
    local repo_name=$(basename "$REPO_URL" .git)

    if [ -d "$repo_name" ]; then
        echo "Repository folder '$repo_name' already exists, skipping clone"
        cd "$repo_name"
        return 0
    fi

    echo "Cloning in: $(pwd)"

    if [ -n "$GITLAB_TOKEN_ENTITY" ]; then
        echo "Using GITLAB_TOKEN_ENTITY for authentication"
        local auth_url=$(echo "$REPO_URL" | sed "s|https://github.com|https://${GITLAB_TOKEN_ENTITY}@github.com|")
        git clone "$auth_url"
    else
        echo "WARNING: No GITLAB_TOKEN_ENTITY found, attempting clone without authentication"
        git clone "$REPO_URL"
    fi

    cd "$repo_name"
    echo "Repository cloned successfully"
}

find_ci_file() {
    log_section "Finding CI File"

    CI_FILE=".github/workflows/ci.yml"

    if [ ! -f "$CI_FILE" ]; then
        log_error "No CI file found at .github/workflows/ci.yml"
        exit 1
    fi

    echo "CI_FILE: $CI_FILE"
}

get_metadata_application() {
    log_section "Fetching Application Metadata"

    local metadata_json=$(np metadata read --id "$APPLICATION_ID" --entity application --format json)

    if [ -z "$metadata_json" ]; then
        log_error "Could not fetch application metadata"
        exit 1
    fi

    echo "Metadata JSON:"

    # Extract metadata fields (from metadata_application_playground object)
    AUTOR_PROYECTO=$(echo "$metadata_json" | jq -r '.metadata_application_playground["Autor del Proyecto"] // empty')
    DESCRIPCION_MICROSERVICIO=$(echo "$metadata_json" | jq -r '.metadata_application_playground["Descripción del Microservicio"] // empty')
    GRUPO=$(echo "$metadata_json" | jq -r '.metadata_application_playground["Grupo"] // empty')
    IDENTIFICADOR_BACKEND=$(echo "$metadata_json" | jq -r '.metadata_application_playground["Identificador Backend"] // empty')
    NOMBRE_AGILE_TEAM=$(echo "$metadata_json" | jq -r '.metadata_application_playground["Nombre del Agile Team"] // empty')
    RUTA_MICROSERVICIO=$(echo "$metadata_json" | jq -r '.metadata_application_playground["Ruta del Microservicio"] // empty')

    # Echo each field
    log_section "Metadata Fields"
    echo "Autor del Proyecto: $AUTOR_PROYECTO"
    echo "Descripción del Microservicio: $DESCRIPCION_MICROSERVICIO"
    echo "Grupo: $GRUPO"
    echo "Identificador Backend: $IDENTIFICADOR_BACKEND"
    echo "Nombre del Agile Team: $NOMBRE_AGILE_TEAM"
    echo "Ruta del Microservicio: $RUTA_MICROSERVICIO"
}

modify_ci_file() {
    log_section "Modifying CI File"
    echo "# Modified by entity-hooks" >> "$CI_FILE"
}

commit_and_push() {
    log_section "Committing and Pushing Changes"

    git config user.email "agustin@nullplatform.io"
    git config user.name "Agustin"

    git add .github/workflows/ci.yml

    if git diff --cached --quiet; then
        echo "No changes to commit"
        return 0
    fi

    git commit -m "chore: update CI workflow via entity hooks"
    git push origin HEAD

    echo "Changes pushed successfully!"
}

# ==============================================================================
# Main
# ==============================================================================
main() {
    echo "=========================================="
    echo "=== Starting replace_gitlab_values.sh ==="
    echo "=========================================="

    extract_application_id
    get_metadata_application
    fetch_repository_url
    clone_repository
    find_ci_file
    modify_ci_file
    commit_and_push

    echo ""
    echo "=========================================="
    echo "=== Script completed successfully ==="
    echo "=========================================="
}

main
