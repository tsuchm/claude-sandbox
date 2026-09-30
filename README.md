# Claude Code SandBox

## 使い方

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
