if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
    DISTRO=$(lsb_release -is)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "cygwin" ]]; then
    OS="Windows (Cygwin)"
elif powershell.exe -Command "[System.Environment]::GetEnvironmentVariable('PSVersionTable')" > /dev/null 2>&1; then
    OS="Windows (PowerShell)"
else
    OS="Unknown"
fi
echo "current OS: $OS"
case "$OS" in
    "Linux")
        # install dependency
        sudo apt update
        while read line; do
            sudo apt install $line
        done < requirements.txt
        ;;
    "macOS")
        # check whether brew is installed
        if ! command -v brew &> /dev/null
        then
            echo "brew could not be found, please install it first"
            exit 1
        fi
        # install dependency
        while read line; do
            brew install $line
        done < requirements.txt
        ;;
    "Windows (Cygwin)")
        # install dependency
        while read line; do
            cygcheck -p $line
        done < requirements.txt
        ;;
    "Windows (PowerShell)")
        # check whether choco is installed
        if ! command -v choco &> /dev/null
        then
            echo "choco could not be found, please install it first"
            #install choco
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            exit 1
        fi
        # install dependency
        while read line; do
            choco install $line
        done < requirements.txt
        ;;
esac
# read requirements from requirements.txt
