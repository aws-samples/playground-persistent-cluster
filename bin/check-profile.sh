[ -t 1 ] && GREP_OPTS="--color=always"

# The [^=]* is to color the env var name only (i.e., excluding the '=').
env | sort | egrep ${GREP_OPTS} '^SMHP[^=]*|^PATH[^=]*'
