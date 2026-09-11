# AI System Rules — CachyOS + Hyprland Gaming Laptop

**Target machine:** CachyOS rolling (BORE/EEVDF, x86-64-v3) · Hyprland (Wayland) @ 1920x1200 165Hz
**Hardware:** Intel i5-13450HX + GeForce RTX 5050 Mobile (Optimus hybrid) · Btrfs on NVMe · fish + Alacritty

Save this file as **`AGENTS.md`** in your project root for per-project rules, or
**`~/.gemini/AGENTS.md`** for it to apply globally across every project — Antigravity CLI
reads both automatically, no flag or registration step needed. (If you also use Claude Code
or Cursor, both of those now read `AGENTS.md` too, so this one file covers all three.)

---

## 1. Global Behavior Rules

- **Token discipline:** never print full config files or command dumps unless asked. Use
  unified diffs or targeted line replacements for dotfile edits.
- **No unverified "verified" claims.** Before reporting a package, MCP server, or tool as
  installed/working, actually check (`pip show`, `npm ls -g`, `which`, or the real repo page).
  Don't report specific version numbers you haven't confirmed.
- **Accurate performance language.** Say tearing/`immediate` window rules *reduce* input
  latency — never claim they bring it to "zero."
- **Snapshot before system changes.** Before `pacman -Syu`, `yay`, `paru`, or any package
  install/removal, confirm a Snapper pre-update snapshot exists or trigger one first.
- **Never run `pacman -Sy`** (partial upgrade risk) — always `pacman -Syu`.
- **Never put a raw secret/token in this file or in any command it runs.**

---

## 2. Hybrid GPU Strategy (Intel iGPU + RTX 5050 Mobile)

- Desktop session and 2D apps run on the **Intel iGPU** for idle power/thermals. Set:
  ```
  env = LIBVA_DRIVER_NAME,iHD
  ```
  (not `nvidia` — that fights the power-saving goal by pulling the whole session onto the dGPU.)
- Games/3D/CUDA offload to the RTX 5050 explicitly, never globally:
  ```
  gamemoderun prime-run %command%
  ```
- Keep the dGPU suspended (D3cold) until something actually requests it.

---

## 3. Hyprland Window Rules (corrected)

```ini
windowrulev2 = immediate, class:^(steam_app_.*)$
windowrulev2 = fullscreen, class:^(steam_app_.*)$
windowrulev2 = workspace 5, class:^(steam_app_.*)$
```

Keep each rule on its own line — a merged/escaped single line will fail to parse.

---

## 4. Btrfs / Snapper Safety

- `chattr +C` (no-CoW) only affects files written **after** it's set. For an existing Steam
  library: move the data out, `chattr +C` the empty directory, move the data back in.
- If granting an agent sudo access to `snapper`/`btrfs`: **scope the sudoers rule to specific
  snapper subcommands** (e.g. `create`, `list`, `rollback`), not a blanket passwordless `btrfs`
  binary. Raw `btrfs` can delete subvolumes and snapshots outright — don't hand that out
  passwordless.

---

## 5. MCP Server Configuration

Prefer official, narrow servers over large custom ones — lower token overhead, easier to audit.

```json
{
  "mcpServers": {
    "official-filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem",
                "/home/manisk/.local/share/chezmoi", "/home/manisk/.config"]
    },
    "official-git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"]
    },
    "official-fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    },
    "official-github": {
      "command": "/home/manisk/.local/bin/github-mcp-wrapper",
      "args": []
    }
  }
}
```

Before adding any third-party MCP server (btrfs-snapper, systemd, gpu-tuning, steam, etc.),
confirm it's real: check the actual PyPI/npm/GitHub page, not just a name someone mentioned.

---

## 6. Secret Handling (chezmoi + age)

**Never commit a plaintext token** — not even as a placeholder — as an unencrypted source file.
Since you're using chezmoi's `age` encryption, fill in the real token locally, then add the
*whole file* as encrypted, rather than templating a password-manager call:

```bash
chezmoi add --encrypt ~/.config/mcp/mcp_config.json
```

This stores it in your source repo as an `encrypted_` file (ASCII-armored age ciphertext) and
`chezmoi apply` decrypts it automatically using the identity/recipient set in
`~/.config/chezmoi/chezmoi.toml` (`encryption = "age"`, plus your `[age] identity` /
`recipient`). To edit it later, use `chezmoi edit` — it decrypts, opens your editor, and
re-encrypts on save. Never run a plain `chezmoi add` on this file once it contains the real
token.

---

## 7. Community Tools — Verify Before Trusting

Names like `hypruse`, `hyprmcp`, or "community-vetted" server lists should be checked against
their real GitHub pages (commit activity, real usage) before wiring them in — not taken on
the strength of a description alone.
