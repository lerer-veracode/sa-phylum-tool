## SA Phylum Tool
The SA Phylum utility was made to support demo processes with easy commands to turn on/off the Phylum firewall feature.
> if needed, we can enhance the script to use MAVEN, PyPi or others. As well we can modify it to use the GROUPs instead of FIREWALL

In order to set it up, you'll need to create a file name: `phylum` at the `.veracode` folder. 

The content of the `phylum` file should be as follow:
```
FIREWALL_NAME="your-firewall-name"
PHYLUM_API_KEY="your-phylum-api-key"
```
---

## Here are the steps to enable the script on macOS:

### 1. Move the Script

First, move the `sa-phylum.sh` script into the desired folder. I'm assuming the script is currently in your present working directory.

Bash

```
# Move the script into the new directory
mv sa-phylum.sh "$HOME/.veracode/"
```

---

### 2. Make the Script Executable

Ensure the script has execute permissions. You might have already done this, but it's good to double-check.

Bash

```
chmod +x "$HOME/.veracode/sa-phylum.sh"
```

---

### 3. Add the Directory to Your PATH

The `PATH` is an environment variable that tells your shell which directories to search for executable files. By adding your script's directory to the `PATH`, you can run it from anywhere.

Modern macOS versions use Zsh as the default shell. You'll need to edit the `~/.zshrc` file.

Bash

```
# Add the new directory to your PATH by appending a line to .zshrc
echo 'export PATH="$HOME/.veracode:$PATH"' >> ~/.zshrc
```

- **What this command does:** It adds the line `export PATH="$HOME/.veracode:$PATH"` to the end of your Zsh configuration file. This tells the shell to look in your new directory _first_ before searching the other directories in the `PATH`.
    

---

### 4. Apply the Changes

The changes you made to the `.zshrc` file won't take effect until you either open a new terminal window or "source" the file in your current session.

Bash

```
# Apply the changes to your current terminal session
source ~/.zshrc
```

---

### 5. Verify It Works

Now you should be able to run the script from any directory. You can test it by moving to your home directory and running the script's help command.

Bash

```
# Go to a different directory (e.g., your home directory)
cd ~

# Test the script
sa-phylum.sh -h
```

If it's set up correctly, you will see the help message from the script.