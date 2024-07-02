#
# Supabase
#
# Supabase is a supa-dupa cool tool for making you development easier.
# Link: https://www.supabase.io

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_SUPABASE_SHOW="${SPACESHIP_SUPABASE_SHOW=true}"
SPACESHIP_SUPABASE_ASYNC="${SPACESHIP_SUPABASE_ASYNC=true}"
SPACESHIP_SUPABASE_PREFIX="${SPACESHIP_SUPABASE_PREFIX="linked to "}"
SPACESHIP_SUPABASE_SUFFIX="${SPACESHIP_SUPABASE_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_SUPABASE_SYMBOL="${SPACESHIP_SUPABASE_SYMBOL="󱐋 "}"
SPACESHIP_SUPABASE_COLOR="${SPACESHIP_SUPABASE_COLOR="#85E0B7"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Define the cache file location and the cache duration (in seconds)
CACHE_FILE="$HOME/.cache/supabase_projects_cache"
CACHE_DURATION=600  # 10 minutes

# Function to check if the cache is still valid
is_cache_valid() {
  if [[ -f "$CACHE_FILE" ]]; then
    local cache_mtime
    cache_mtime=$(stat -c %Y "$CACHE_FILE")
    local current_time
    current_time=$(date +%s)
    local age=$((current_time - cache_mtime))
    [[ $age -lt $CACHE_DURATION ]]
  else
    return 1
  fi
}

# Function to update the cache
update_cache() {
  supabase projects list > "$CACHE_FILE"
}

spaceship_supabase() {
  [[ $SPACESHIP_SUPABASE_SHOW == false ]] && return
  spaceship::exists supabase || return
  [ ! -f supabase/.temp/project-ref ] && return

  local supabase_project_name

  if ! is_cache_valid; then
    echo "Updating cache"
    update_cache
  fi
  supabase_project_name="$(awk -F '│' '$1 ~ /●/ { gsub(/^ +| +$/, "", $4); print $4 }' "$CACHE_FILE")"

  spaceship::section::v4 \
    --color "$SPACESHIP_SUPABASE_COLOR" \
    --prefix "$SPACESHIP_SUPABASE_PREFIX" \
    --suffix "$SPACESHIP_SUPABASE_SUFFIX" \
    --symbol "$SPACESHIP_SUPABASE_SYMBOL" \
    "$supabase_project_name"
}
