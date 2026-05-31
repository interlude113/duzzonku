# ✈️ TripNote

旅行の予算管理をシンプルに。旅行ごとに支出を記録し、残高をリアルタイムで確認できるWebアプリです。

**デモ**: https://duzzonku-eta.vercel.app

## 技術スタック

| カテゴリ       | 技術                                       |
| -------------- | ------------------------------------------ |
| フロントエンド | React / TypeScript / Tailwind CSS          |
| バックエンド   | Laravel 13 (REST API)                      |
| 認証           | Laravel Sanctum                            |
| データベース   | MySQL 8.0                                  |
| インフラ       | Docker / docker-compose                    |
| デプロイ       | Vercel (Frontend) / Railway (Backend + DB) |
| バージョン管理 | GitHub                                     |

---

## 技術選定理由

### React + TypeScript

コンポーネント単位での開発により、UIの再利用性と保守性が高い。TypeScriptを採用することで型安全性を確保し、バグを事前に防げる。

### Laravel

PHPフレームワークの中で最もエコシステムが充実しており、REST APIの構築が容易。Sanctumによる認証実装がシンプルで学習コストが低い。

### Docker

開発環境をコンテナ化することで「自分のPCでは動くのに本番では動かない」という問題を排除。チーム開発での環境差異をなくすことができる。

### Vercel + Railway

フロントエンドはVercel、バックエンドはRailwayに分けることで、それぞれの得意領域に特化したデプロイが可能。どちらもGitHubと連携しており、pushするだけで自動デプロイされる。

---

## 機能一覧

- ユーザー登録 / ログイン / ログアウト
- 旅行の登録 / 一覧表示 / 削除
- 支出の入力 / 一覧表示 / 削除
- 合計支出 / 残高のリアルタイム表示
- カテゴリ別支出管理（食費・交通・宿泊・観光・買い物・その他）

---

## ローカル環境での起動方法

### 必要な環境

- Docker Desktop
- Node.js v18以上
- PHP 8.4以上
- Composer

### 手順

**1. リポジトリのクローン**

```bash
git clone https://github.com/interlude113/duzzonku.git
cd duzzonku/travel-budget-app
```

**2. バックエンドの設定**

```bash
cd backend
cp .env.example .env
```

`.env` を編集してDB情報を設定:

```env
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=travel_budget
DB_USERNAME=laravel
DB_PASSWORD=your_password
```

**3. Dockerを起動**

```bash
cd ..
docker-compose up -d --build
```

**4. Laravelの初期設定**

```bash
docker-compose exec backend bash
php artisan key:generate
php artisan migrate
exit
```

**5. フロントエンドの設定**

```bash
cd frontend
npm install
```

`src/lib/axios.ts` の `baseURL` をローカルに変更:

```typescript
baseURL: "http://localhost:8000/api";
```

**6. フロントエンドを起動**

```bash
npm run dev
```

ブラウザで http://localhost:5173 を開く

---

## ディレクトリ構成

```
travel-budget-app/
├── backend/          # Laravel API
│   ├── app/
│   │   ├── Http/Controllers/
│   │   └── Models/
│   ├── database/migrations/
│   └── routes/api.php
├── frontend/         # React + TypeScript
│   ├── src/
│   │   ├── contexts/   # 認証状態管理
│   │   ├── lib/        # axios設定
│   │   └── pages/      # 各画面
│   └── vercel.json
├── Dockerfile
└── docker-compose.yml
```
