#
# Supabase
#
# Supabase is a supa-dupa cool tool for making your development easier.
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

# Define the cache directory and duration (in seconds)
CACHE_DIR="$HOME/.cache/supabase_projects_cache"
CACHE_DURATION=600  # 10 minutes

# Ensure the cache directory exists
mkdir -p "$CACHE_DIR"

# Safely delete all cache files in the directory
find "$CACHE_DIR" -type f -name '*_cache' -delete

# Function to get the directory-specific cache file path
get_cache_file() {
  echo "$CACHE_DIR/$(echo "$PWD" | md5sum | cut -d ' ' -f 1)_cache"
}

# Function to check if the cache is still valid
is_cache_valid() {
  local cache_file
  cache_file=$(get_cache_file)
  if [[ -f "$cache_file" ]]; then
    local cache_mtime
    cache_mtime=$(stat -c %Y "$cache_file")
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
  local cache_file
  cache_file=$(get_cache_file)
  supabase projects list | awk -F '│' '$1 ~ /●/ { gsub(/^ +| +$/, "", $4); print $4 }' > "$cache_file"
}

spaceship_supabase() {
  [[ $SPACESHIP_SUPABASE_SHOW == false ]] && return
  spaceship::exists supabase || return

  local cache_file
  cache_file=$(get_cache_file)
  local supabase_project_name

  if ! is_cache_valid; then
    update_cache
  fi

  supabase_project_name="$(cat "$cache_file")"

  if [[ -z "$supabase_project_name" ]]; then
    return
  fi

  spaceship::section::v4 \
    --color "$SPACESHIP_SUPABASE_COLOR" \
    --prefix "$SPACESHIP_SUPABASE_PREFIX" \
    --suffix "$SPACESHIP_SUPABASE_SUFFIX" \
    --symbol "$SPACESHIP_SUPABASE_SYMBOL" \
    "$supabase_project_name"
}
