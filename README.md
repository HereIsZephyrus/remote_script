# Access channingTong work station by shell

This is a script to access channingTong work station by shell.

## installations

Run git clone command to clone the repository to your local machine.

```bash
git clone https://github.com/HereIsZephyrus/remote_script
```

Then run the setup script to install the script.
If you use Windows, please run the following command in PowerShell as Administrator.

```bash
cd remote_script
bash ./setup.sh
# Input your username to register the SSH. And enter your computer password to install the script.
```

## Usage

```bash
connectTong sftp
# Connect to channingTong work station for file services.
connectTong sshd
# Connect to channingTong work station for computing services.
connectTong pull <remote_file_path> <local_file_path>
# Pull a file from channingTong work station to your local machine.
connectTong push <local_file_path> <remote_file_path>
# Push a file from your local machine to channingTong work station.
```

`notice` If you use Windows, please run the command under this folder.
