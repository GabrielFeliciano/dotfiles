# Secrets Setup

Run these steps after `nixos-rebuild switch` (which installs `age`), before rebuilding again.

## 1. Generate an age key

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

The file will contain something like:
```
# created: 2024-01-01T00:00:00+00:00
# public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

## 2. Add your public key to .sops.yaml

Copy the `age1...` public key from the file above and replace the placeholder in `.sops.yaml`:

```yaml
keys:
  - &gabriel age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## 3. Encrypt the secrets file

```bash
cd ~/nixos-config
sops --encrypt --in-place secrets/secrets.yaml
```

The file will be replaced with an encrypted version — safe to commit.

## 4. Rebuild

```bash
sudo nixos-rebuild switch
```

## 5. Rotate the Anthropic API key

The old key was committed in plaintext and must be considered compromised.
Generate a new one at https://console.anthropic.com and re-encrypt:

```bash
sops secrets/secrets.yaml
# edit the value, save and exit — sops re-encrypts automatically
```
