# .anv
A proposed alternative to fix .env
**anv** kills `.env` files. Secrets stay encrypted. Git stays clean Your code never changed.

## why anv
 | .env problems | .anv solutions |
 |  -----  | ----- |
 | plaintext secret on disk | AES-256-CBC encrypted  with hmac | 
 | Accidental git commit | ENCRYPTED store gitignored master keys |
 | AI agents read your secrets | ENCRYPTED blob = gibberish |
 | Dotenv library support | cli simple interface | 
 | No structure | JSON + CLI |

 ## install
 - on liner install command 
 ```bash
 curl -fsl https://raw.githubusercontent.com/slick-lab/.anv/refs/heads/main/install.sh | sh
```

##  build 
```bash
git clone https://github.com/slick-lab/.anv.git
cd .anv
crystal build src/anv.cr -o anv
sudo mv anv /usr/local/bin/
```
## Quick start

```bash
cd my-project
anv init
anv set DB=postgres://localhost...
anv set API_KEY=1222
anv get API_KEY
anv run -- node index.js
```

## commands
- anv init
   creates .anv/ directory, master key, encrypted store
- anv set KEY=value
   encrypts and store value
- anv get KEY
   decrypts and returns the value
- anv run -- cmd
    runs command with secrets injected as env vars

## How it works 
your code stays the same 
```javascript
  const dburl = process.env.DB_URL
```
you just change how you run it 

## Security
- AES-256-CBC + HMAC encryption
- Master key stored separatelyand gitignored
- Encrypted file safe to commit
- Atomic writes prevents corruption
- File locking prevents concurrent writes
- Secrets lived only in child process memory 

 
