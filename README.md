# 🗄️ Automated DB Backups
**Maintainer:** Khelif Hadil  
**Project URL:** [https://roadmap.sh/projects/automated-backups](https://roadmap.sh/projects/automated-backups)

A scheduled GitHub Actions workflow that automatically backs up a MongoDB database every 12 hours and uploads the compressed backup to Backblaze B2 (S3-compatible storage). Includes a restore script to recover the database from any backup.

---

## 📌 Project Goal

Database backups are critical to any production system. This project demonstrates how to automate the entire backup lifecycle — **dump, compress, upload, and prune** — without managing any additional infrastructure.

> Built by **Khelif Hadil** as part of the [roadmap.sh DevOps projects](https://roadmap.sh/projects/automated-backups).

---

## 🏗️ Architecture

```text
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
| :--- | :--- |
| **Database** | MongoDB Atlas (free M0 tier) |
| **Scheduler** | GitHub Actions (cron) |
| **Backup tool** | `mongodump` (MongoDB Database Tools) |
| **Storage** | Backblaze B2 (S3-compatible, free tier) |
| **Upload tool** | AWS CLI (pointed at B2 endpoint) |

---

## 📁 Project Structure

```bash
.
├── .github/
│   └── workflows/
│       └── db-backup.yml    # Runs every 12h, dumps & uploads backup
├── scripts/
│   ├── backup.sh           # Manual backup script (alternative to Actions)
│   └── restore.sh          # Downloads latest backup from B2 & restores DB
├── .env.example            # Environment variable template
└── README.md
```

---

## ⚙️ Setup

### 1. MongoDB Atlas
* Create a free M0 cluster at [mongodb.com/atlas](https://www.mongodb.com/atlas).
* Create a database user with **read/write** access.
* Under **Network Access**, allow connections from `0.0.0.0/0`.
* Copy your connection string:
  `mongodb+srv://<user>:<password>@cluster0.xxxxx.mongodb.net`

### 2. Backblaze B2 Storage
* Create a free account at [backblaze.com](https://www.backblaze.com).
* Create a bucket (e.g., `mongo-backups`).
* Generate an **App Key** with Read & Write access.
* Note your bucket endpoint (e.g., `https://s3.us-east-005.backblazeb2.com`).

### 3. GitHub Secrets
Navigate to **Settings > Secrets and variables > Actions** and add:

| Secret | Description |
| :--- | :--- |
| `MONGO_URI` | Full MongoDB Atlas connection string |
| `DB_NAME` | Name of the database to back up |
| `R2_ACCESS_KEY_ID` | Backblaze B2 App Key ID |
| `R2_SECRET_ACCESS_KEY` | Backblaze B2 App Key |
| `R2_ENDPOINT` | Your B2 S3-compatible endpoint |
| `R2_BUCKET` | Your B2 bucket name |

---

## 🕐 Schedule

The workflow runs automatically on this cron schedule:

```yaml
on:
  schedule:
    - cron: '0 0,12 * * *'  # Every day at 00:00 and 12:00 UTC
```

---

## 🔁 Restore (Recovery)

To restore the database from the latest backup:

```bash
chmod +x scripts/restore.sh
./scripts/restore.sh
```

**The script performs the following:**
1. Lists all backups in B2 and selects the **latest** one.
2. Downloads and extracts the tarball.
3. Prompts for confirmation before overwriting the database.
4. Executes `mongorestore --drop` for a clean restoration.

---

## 🧹 Backup Retention

The workflow automatically keeps only the **10 most recent backups**. It deletes older files from the B2 bucket to ensure you stay within the free storage limits.

---

## 👤 Author

**Khelif Hadil** *DevOps enthusiast and backend & database developer.*

---

## 📄 License

MIT

