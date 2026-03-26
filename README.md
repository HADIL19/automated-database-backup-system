# 🗄️ Automated DB Backups

A scheduled GitHub Actions workflow that automatically backs up a MongoDB database every 12 hours and uploads the compressed backup to Backblaze B2 (S3-compatible storage). Includes a restore script to recover the database from any backup.

---

## 📌 Project Goal

Database backups are critical to any production system. This project demonstrates how to automate the entire backup lifecycle — dump, compress, upload, and prune — without managing any additional infrastructure.

> Built as part of the [roadmap.sh DevOps projects](https://roadmap.sh/projects/automated-db-backups).

---

## 🏗️ Architecture

```
GitHub Actions (every 12 hours)
        │
        ▼
  mongodump → mydb_20260326_120000.tar.gz
        │
        ▼
  aws s3 cp → Backblaze B2 bucket
        │
        ▼
  Prune old backups (keep latest 10)
```

---

## 🧰 Stack

| Component | Tool |
|---|---|
| Database | MongoDB Atlas (free M0 tier) |
| Scheduler | GitHub Actions (cron) |
| Backup tool | `mongodump` (MongoDB Database Tools) |
| Storage | Backblaze B2 (S3-compatible, free tier) |
| Upload tool | AWS CLI (pointed at B2 endpoint) |

---

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── db-backup.yml   # Runs every 12h, dumps & uploads backup
├── scripts/
│   ├── backup.sh           # Manual backup script (alternative to Actions)
│   └── restore.sh          # Downloads latest backup from B2 & restores DB
├── .env.example            # Environment variable template
└── README.md
```

---

## ⚙️ Setup

### 1. MongoDB Atlas

- Create a free M0 cluster at [mongodb.com/atlas](https://www.mongodb.com/atlas)
- Create a database user with read/write access
- Under **Network Access**, allow connections from anywhere: `0.0.0.0/0`
- Copy your connection string:
  ```
  mongodb+srv://<user>:<password>@cluster0.xxxxx.mongodb.net
  ```

### 2. Backblaze B2 Storage

- Create a free account at [backblaze.com](https://www.backblaze.com) (no credit card needed)
- Create a bucket (e.g. `mongo-backups`)
- Generate an **App Key** with Read & Write access to the bucket
- Note your bucket endpoint (e.g. `https://s3.us-east-005.backblazeb2.com`)

### 3. GitHub Secrets

Go to your repo → **Settings** → **Secrets and variables** → **Actions** and add:

| Secret | Description |
|---|---|
| `MONGO_URI` | Full MongoDB Atlas connection string |
| `DB_NAME` | Name of the database to back up |
| `R2_ACCESS_KEY_ID` | Backblaze B2 App Key ID |
| `R2_SECRET_ACCESS_KEY` | Backblaze B2 App Key |
| `R2_ENDPOINT` | `https://s3.us-east-005.backblazeb2.com` |
| `R2_BUCKET` | Your B2 bucket name |

---

## 🕐 Schedule

The workflow runs automatically on this cron schedule:

```yaml
- cron: '0 0,12 * * *'  # Every day at 00:00 and 12:00 UTC
```

You can also trigger it manually from the **Actions** tab → **Run workflow**.

---

## 🔁 Restore (Stretch Goal)

To restore the database from the latest backup:

```bash
export MONGO_URI="mongodb+srv://user:pass@cluster.mongodb.net"
export DB_NAME="mydb"
export R2_BUCKET="mongo-backups"
export R2_ENDPOINT="https://s3.us-east-005.backblazeb2.com"
export AWS_ACCESS_KEY_ID="your_key_id"
export AWS_SECRET_ACCESS_KEY="your_app_key"

chmod +x scripts/restore.sh
./scripts/restore.sh
```

The script will:
1. List all backups in B2 and pick the latest one
2. Download and extract the tarball
3. Ask for confirmation before overwriting the database
4. Run `mongorestore --drop` to fully restore the data

To restore a specific backup instead of the latest:
```bash
./scripts/restore.sh mydb_20260326_120000.tar.gz
```

---

## 🧹 Backup Retention

The workflow automatically keeps only the **10 most recent backups** and deletes older ones from B2 to stay within the free tier limits.

---

## 📄 License

MIT