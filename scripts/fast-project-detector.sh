#!/bin/bash

# Fast project type detection for UNIVERSAL MODE
detect_project_fast() {
    local cwd=${1:-$(pwd)}
    local confidence=0
    local type="generic"

    # Quick file checks (most common first)
    if [[ -f "$cwd/package.json" ]]; then
        confidence=40
        if grep -q '"next"' "$cwd/package.json" 2>/dev/null; then
            type="nextjs"; confidence=85
        elif grep -q '"react"' "$cwd/package.json" 2>/dev/null; then
            type="react"; confidence=80
        elif grep -q '"vue"' "$cwd/package.json" 2>/dev/null; then
            type="vue"; confidence=80
        elif grep -q '"express"' "$cwd/package.json" 2>/dev/null; then
            type="nodejs-backend"; confidence=75
        else
            type="nodejs"; confidence=60
        fi

        # TypeScript bonus
        if [[ -f "$cwd/tsconfig.json" ]]; then
            confidence=$((confidence + 10))
        fi
    elif [[ -f "$cwd/requirements.txt" ]] || [[ -f "$cwd/pyproject.toml" ]]; then
        confidence=50
        if grep -q "django\|fastapi\|flask" "$cwd/requirements.txt" "$cwd/pyproject.toml" 2>/dev/null; then
            type="python-web"; confidence=80
        elif grep -q "pandas\|numpy\|scikit\|tensorflow\|pytorch" "$cwd/requirements.txt" "$cwd/pyproject.toml" 2>/dev/null; then
            type="data-science"; confidence=85
        else
            type="python"; confidence=60
        fi
    elif [[ -f "$cwd/Cargo.toml" ]]; then
        type="rust"; confidence=85
    elif [[ -f "$cwd/go.mod" ]]; then
        type="go"; confidence=85
    elif [[ -f "$cwd/composer.json" ]]; then
        type="php"; confidence=80
    fi

    # Infrastructure detection
    if [[ -f "$cwd/terraform.tf" ]] || [[ -d "$cwd/terraform" ]]; then
        type="infrastructure"; confidence=90
    elif [[ -f "$cwd/Dockerfile" ]]; then
        confidence=$((confidence + 15))
    fi

    echo "$type:$confidence"
}

# Export and run
export -f detect_project_fast
detect_project_fast "$@"
