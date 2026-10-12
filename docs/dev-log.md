# Dev Log

## 2026-10-10
- Created Azure free account and $30 monthly budget alert
- Installed Git, Azure CLI, Terraform, Python 3.11, Databricks CLI (fixed PATH issue after Azure CLI install)
- Fixed Git Bash bracketed-paste issue via ~/.inputrc
- Resolved diverged-branch push rejection with git reset --hard origin/main
- Created repo and project folder structure
- Wrote Terraform (providers, variables, main, outputs) and deployed RG + ADLS Gen2 (HNS enabled) with bronze/silver/gold containers
- Hardened storage: TLS 1.2 minimum, private containers, public blob access blocked at account level
- Used saved-plan workflow: plan -out=tfplan, then apply tfplan
- Debugged empty .tf files and heredoc commands pasted into the editor instead of the terminal
- Moved Terraform state to Azure Storage (versioned container) via terraform init -migrate-state; removed local state files
- Added Key Vault (RBAC mode), granted myself Key Vault Secrets Officer, stored data lake access key as first secret

## 2026-10-11
- Terraform: Databricks workspace (premium) + access connector with Storage Blob Data Contributor on the lake
- Connected Databricks to GitHub via fine-grained PAT (single repo, Contents read/write) and Git folder
- Created single-node cluster: 17.3 LTS, Photon off, Dedicated access, 20-min auto-terminate (0.75 DBU/h)
- Unity Catalog: storage credential (managed identity) + external locations for bronze/silver/gold; file events intentionally not enabled
- Wrote/read first Delta table to bronze via abfss path; merged PR #1 with squash merge
- Terraform: Data Factory with system-assigned identity + Storage Blob Data Contributor on the lake
- Fixed linked service type: azurerm web linked service = ADF "Web Table"; switched to custom HttpServer for file downloads
- Built pl_ingest_bts_month (HTTP Binary + ZipDeflate -> ADLS Binary); fixed preserveZipFileNameAsFolder default creating extra subfolder
- Built pl_backfill_bts_year (ForEach, batch 4) -> loaded all 12 months of 2025: 7,001,619 flights in bronze
- Connected ADF to GitHub (root /adf, collaboration branch main, publish branch adf_publish)
- Cleaned up stray recreated branch from Databricks; learned to check branch before committing

## Phase 4 wrap: ADF → Databricks + flight_key fix
- ADF pl_monthly_bts_refresh loaded Jan 2026 and triggered the medallion job end to end
- Reconciliation: silver 1 row short of bronze (7,545,621 vs 7,545,622)
- Root cause: F9 3237 on 2026-01-04, two JFK legs at 06:59 to different dests; flight_key omitted dest
- Fix: added dest to the flight_key hash, rebuilt silver from bronze, reran job → 7,545,622 rows, 7,545,622 unique keys
- Hit 4 vCPU regional quota: interactive cluster + job cluster competed; terminated interactive cluster before job run
- ADF tr_monthly_bts_refresh: schedule trigger, 20th of each month 06:00 UTC; pipeline params default to "" so the run auto-computes month (now − 2)
