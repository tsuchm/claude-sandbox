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

## GPU の有無による起動方法の切り替え

GPU 設定は `docker-compose-gpu.yml` に分離されている。`docker-compose.yml` 単体では GPU を要求しないため、NVIDIA GPU のないサーバでもそのまま起動できます。

| ファイル | 内容 |
| --- | --- |
| `docker-compose.yml` | 共通設定(GPU 設定なし) |
| `docker-compose-gpu.yml` | GPU 用の追加設定(NVIDIA GPU を全て割り当て) |

### GPU なしのサーバ

```bash
docker compose up -d
```

### GPU ありのサーバ

毎回 `-f` を指定する方法:

```bash
docker compose -f docker-compose.yml -f docker-compose-gpu.yml up -d
```

または、GPU ありサーバ上の `.env` に次の1行を書いておけば、通常のコマンドで両ファイルが読み込まれる。

```
COMPOSE_FILE=docker-compose.yml:docker-compose-gpu.yml
```

```bash
docker compose up -d
```

## Configuration for Emacs to use claude-code.el

[claude-code.el](https://github.com/stevemolitor/claude-code.el) を利用する場合、このディレクトリにある `claude-wrapper.sh` を、パスが通っている適当なディレクトリに `claude` というファイル名でシンボリックリンクする。

```sh
cd ~/.local/bin/
ln -s ~/claude-sandbox/claude-wrapper.sh claude
```

その上で、以下の設定を書く。

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
