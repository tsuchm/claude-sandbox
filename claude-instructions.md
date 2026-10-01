# サンドボックス環境

あなたは Docker コンテナ内で動いている。前提は次のとおり。

- 実行ユーザーは非 root の `ubuntu`。`cap_drop: ALL` と `no-new-privileges` が有効で、sudo や setuid による権限昇格はできない。システム領域への `apt install` もできない。
- docker と podman は使えない。デーモンも docker ソケットもない。docker を試して失敗を確認する必要はない。
- 保存場所の性質は次のとおり。
  - `/workspace/`：ホストと共有している永続的なディレクトリ。成果物、データ、設定、スクリプト、ログなどは、このディレクトリに保存する。

この制限を回避しようとしてはならない。user namespace の作成、ソケットの探索、権限昇格の試行などは行わない。制限のために作業が進められない場合は、試行を重ねる前にユーザーへ報告する。

## 実装中の未解決の選択肢

承認済みの計画に明記されていない設計判断(データ構造、エラーハンドリングの方針、命名、ライブラリの選定など)に実装中に遭遇した場合、auto modeであっても黙って選ばずにAskUserQuestionツールで選択肢を提示し、確認を待つこと。

## 別の userland が必要なとき

古い言語処理系(Python 2 など)や別ディストリビューションの環境が必要なときは、次のどちらかの方法で rootfs を用意し、`rootfs-run` で実行する。

```
rootfs-run [--arch ARCH] IMAGE|DIR [CMD...]
```

引数がコンテナイメージ名なら方法A、`/` または `./` で始まるパスなら方法Bで作った rootfs として扱う。

### 方法A: コンテナイメージを使う

```
rootfs-run python:2.7-slim python --version
```

- 初回はレジストリからイメージを取得して `$ROOTFS_DIR` に展開する。2回目以降は、同じコンテナが残っている間はキャッシュを使う。
- 実体は `skopeo` + `umoci` による展開である。

### 方法B: mmdebstrap で Debian / Ubuntu の rootfs を作る

```
mmdebstrap --mode=proot --variant=minbase \
  --include=python2.7,ca-certificates \
  bullseye "$ROOTFS_DIR/debian-bullseye" http://deb.debian.org/debian

rootfs-run "$ROOTFS_DIR/debian-bullseye" python2.7 --version
```

- 作成先は `$ROOTFS_DIR` 以下にする。`rootfs-run` に渡すパスは `/` か `./` で始める。
- パッケージを apt で選べる。取得元はコンテナレジストリではなく apt のミラー。
- 展開時にパッケージの設定スクリプトを proot 上で実行するため、数分かかることがある。
- 終了済みのリリースがミラーにない場合(404、または Release ファイルが見つからない)は、アーカイブを使う。署名の有効期限切れで失敗する場合は、期限の検証を無効にする。

```
  mmdebstrap --mode=proot --variant=minbase \
    --aptopt='Acquire::Check-Valid-Until "false"' \
    --include=python2.7,ca-certificates \
    bullseye "$ROOTFS_DIR/debian-bullseye" http://archive.debian.org/debian
```

- 中断した mmdebstrap の出力は、`chmod -R u+rwX` してから削除する。

### 使い分け

- Debian / Ubuntu のパッケージで組みたい、または特定リリースが欲しい: 方法B
- それ以外のイメージ(言語公式イメージ、Alpine、他社のイメージなど)、または既存イメージをそのまま使いたい: 方法A

### 共通の性質

- 中で見えるのは、rootfs の内容と `/workspace` だけ。ホスト側やこのコンテナのほかのパスは見えない。入出力は `/workspace` 経由で行う。
- ネットワークはこのコンテナと共有される。中でサーバを起動すれば、外側から `localhost:<port>` でアクセスできる。長く動かすサーバは `&` でバックグラウンド実行し、終了時に停止する。
- 中では uid 0 に見えるが、実権限は `ubuntu` のまま。rootfs 内での `apt install` が権限の問題で失敗する場合は、`-o APT::Sandbox::User=root` を付けてみる。

### 制約

- ptrace ベースのため遅い。ファイル走査やビルドなど、システムコールを多用する処理は特に時間がかかる。
- systemd、setuid バイナリ、raw socket(`ping` など)は使えない。
- 起動に失敗する場合は、`PROOT_NO_SECCOMP=1` を付けて再実行する(`rootfs-run` と `mmdebstrap` のどちらにも有効)。

### できないこと

次のような docker 前提の作業は実現できない。必要なときは、回避を試みずユーザーに報告して指示を仰ぐ。

- イメージのビルド(`docker build`)
- 複数コンテナの構成(`docker compose`)
- コンテナ間のネットワーク分離
