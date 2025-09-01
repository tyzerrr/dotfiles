typeset -U path
# path
path=("$HOME/.local/bin"
    "$HOME/go/bin"
    "$DENO_INSTALL_ROOT/bin"
    "$DENO_INSTALL_ROOT/env"
    "$JAVA_HOME/bin"
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
    /opt/homebrew/opt/asdf/libexec/asdf.sh
    "$HOME/.asdf/shims"
    "$GOPATH/bin"
)
export PATH

# MacPorts Installer addition on 2023-03-01_at_13:12:17: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.
eval "$(/opt/homebrew/bin/brew shellenv)"
