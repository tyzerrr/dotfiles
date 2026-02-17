typeset -U path
# path
path=("$HOME/.local/bin"
    "${AQUA_ROOT_DIR}/bin"
    "${MISE_ROOT_DIR}/shims"
    "/opt/homebrew/bin"
    "$NPM_CONFIG_PREFIX/bin"
    "$HOME/go/bin"
    "$DENO_INSTALL_ROOT/bin"
    "$DENO_INSTALL_ROOT/env"
    "$HOME/.cargo/env"
    "/Applications/kitty.app/Contents/MacOS"
    "$HOME/apache-maven-3.9.2/bin"
    "$HOME/go/bin"
    /usr/bin
    /bin
    /usr/sbin
    /sbin
    /usr/local/bin
    /usr/local/cuda/bin
    "$GOPATH/bin"
    "/opt/local/bin:/opt/local/sbin"
    $HOME/.bun/bin
)
export PATH

# MacPorts Installer addition on 2023-03-01_at_13:12:17: adding an appropriate PATH variable for use with MacPorts.
# Finished adapting your PATH environment variable for use with MacPorts.
eval "$(/opt/homebrew/bin/brew shellenv)"
