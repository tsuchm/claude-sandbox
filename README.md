# Claude Code SandBox

## Usage

### 1. ビルド & 起動

```bash
docker compose -f docker-compose.yml up -d --build
```

### 2. コンテナに入る

```bash
docker compose -f docker-compose.yml exec claude-sandbox bash
```

### 3. Claude Codeを起動

```bash
claude
```

### 4. 作業終了時

```bash
docker compose -f docker-compose.yml down
```

## Configuration for Emacs to use claude-code.el

[claude-code.el](https://github.com/stevemolitor/claude-code.el) を利用する場合、このディレクトリにある `claude-wrapper.sh` を、パスが通っている適当なディレクトリに `claude` というファイル名で置く。その上で、以下の設定を書く。

```elisp
(leaf ghostel
  :vc (:url "https://github.com/dakra/ghostel" :rev :newest)
  :custom (ghostel-module-auto-install . 'compile))

(leaf inheritenv :vc (:url "https://github.com/purcell/inheritenv" :rev :newest))

(leaf claude-code
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :require t
  :custom (claude-code-terminal-backend . 'ghostel)
  :config
  (claude-code-mode)
  (global-set-key (kbd "C-c c") claude-code-command-map))
```
