
# anv 
<p align="center">
  <img src="./logo.svg" width="200" alt=".anv logo">
</p>

No .env. No leaks. No AI reading your secrets.

**anv** kills `.env` files. Secrets stay encrypted. Git stays clean. Your code never changes.

## Why anv?

| .env problems | anv solutions |
|---------------|----------------|
| Plaintext secrets on disk | AES-256-CBC + HMAC encrypted |
| Accidental git commit | Encrypted store only (no master key in repo) |
| AI agents read your secrets | Encrypted blob = gibberish |
| Dotenv library required | Simple CLI interface |
| Master key on disk (the ".env paradox") | **Stored in OS system keyring** (not a file) |

## Install

One-line install:

```bash
curl -fsSL https://raw.githubusercontent.com/slick-lab/.anv/refs/heads/master/install.sh | sh
```

## Build from source

```bash
git clone https://github.com/slick-lab/.anv.git
cd .anv
crystal build src/anv.cr -o anv
sudo mv anv /usr/local/bin/
```

Quick start

```bash
cd my-project
anv init                    # master key stored in system keyring
anv set DB_URL=postgres://localhost
anv set API_KEY=12345
anv get API_KEY
anv run -- node index.js
```

## Commands

**Command What it does**
- anv init Creates .anv/ directory, encrypted store, stores master key in OS keyring
- anv set KEY=value Encrypts and stores a secret
- anv get KEY Decrypts and returns the value
- anv rotate rotates the master.key
- anv rm KEY deletes the value
- anv list list all keys 
- anv run -- cmd Runs command with secrets injected as env vars
- anv keys dislplays your current masterkey 
- anv help shows the help message
- anv delete removes the master key from os keyring(use if you know what you are doing)

## How master key is stored (no more ".env paradox")

OS Tool Where the key goes

Linux secret-tool GNOME Keyring / KWallet

macOS security Keychain Access

Other Falls back to .anv/master.key (with warning) Local file (not recommended)

Your LLM cannot read the key. It's not in a file. It's in your OS keyring.

How it works

Your code stays exactly the same:

```javascript
const dbUrl = process.env.DB_URL;
```

You just change how you run it:

```bash
anv run node app.js
```

Security

- AES-256-CBC + HMAC authenticated encryption
- Master key stored in OS system keyring (not on disk, not in shell history)
- Encrypted store safe to commit to version control
- Atomic writes prevent file corruption
- File locking prevents concurrent write conflicts
- Secrets live only in child process memory, never on disk

License

MIT
