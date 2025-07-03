# Project Teardown Guide

## 🧹 Complete Teardown Instructions for Policy as Code Lab

This guide provides step-by-step instructions for safely removing all components of the Policy as Code enforcement lab, including infrastructure, tools, and project files.

## ⚠️ Pre-Teardown Checklist

Before beginning teardown, ensure you have:

- [ ] **Exported important work**: Saved any custom policies or configurations you want to keep
- [ ] **Documented learnings**: Captured key insights for future reference  
- [ ] **Backed up portfolio materials**: Saved screenshots, documentation, or demo recordings
- [ ] **Checked for running resources**: Verified no critical infrastructure is running
- [ ] **Confirmed access**: Ensured you have necessary permissions for cleanup operations

## 🗂️ Teardown Order (Recommended)

Follow this sequence to avoid dependency issues:

1. **Infrastructure Resources** (AWS/Cloud)
2. **Terraform State and Files**
3. **Local Project Files** 
4. **Tools and Dependencies** (Optional)
5. **System Configuration** (Optional)

---

## 1. 🏗️ Infrastructure Teardown

### Check Current Infrastructure State

```bash
# Navigate to terraform directory
cd ~/policy-lab/terraform
# or 
cd "/mnt/c/Users/k.omo/Documents/GitHub.New/Policy Enforcement/terraform"

# Check what resources exist
terraform state list

# Review current infrastructure
terraform show
```

### Destroy Terraform Resources

```bash
# Preview destruction plan
terraform plan -destroy

# Destroy all managed resources
terraform destroy

# If prompted, type 'yes' to confirm
# This will remove:
# - Random ID resources
# - Any S3 buckets (if created)
# - Security groups, VPCs (if created)
# - All other Terraform-managed resources
```

### Verify Destruction

```bash
# Check that state is empty
terraform state list
# Should return no resources

# Verify in AWS Console (optional)
# - Check S3 buckets are removed
# - Verify no unexpected resources remain
```

### Handle Destruction Issues

```bash
# If destroy fails due to dependencies
terraform destroy -target=aws_s3_bucket.company_data
terraform destroy  # Try again

# If state is corrupted
terraform refresh
terraform destroy

# Force removal of state (last resort)
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
# Note: This doesn't destroy actual infrastructure!
```

---

## 2. 🗃️ Terraform Files Cleanup

### Remove Terraform State Files

```bash
# Remove all Terraform state files
rm -f terraform.tfstate
rm -f terraform.tfstate.backup

# Remove lock file
rm -f .terraform.lock.hcl

# Remove provider cache
rm -rf .terraform/

# Remove plan files
rm -f tfplan
rm -f *.tfplan
rm -f plan.json
```

### Remove Terraform Configuration Files (Optional)

```bash
# If you want to remove example files
rm -f main.tf
rm -f violating-s3.tf
rm -f violating-database.tf
rm -f violating-compute.tf
rm -f compliant-s3.tf

# Or backup before removal
mkdir ~/terraform-backup
cp *.tf ~/terraform-backup/
rm -f *.tf
```

### Verify Terraform Cleanup

```bash
# Check terraform directory is clean
ls -la
# Should show only directories or backed up files

# Verify no state files remain
find . -name "*.tfstate*" -type f
find . -name "tfplan*" -type f
find . -name "plan.json" -type f
```

---

## 3. 📁 Project Files Cleanup

### Full Project Removal

```bash
# Navigate to parent directory
cd ~
# or 
cd "/mnt/c/Users/k.omo/Documents/GitHub.New/"

# Remove entire project directory
rm -rf policy-enforcement-lab/
# or
rm -rf "Policy Enforcement"/

# Remove symbolic link
rm -f ~/policy-lab
```

### Selective File Removal

```bash
# Keep project structure but remove generated files
cd ~/policy-lab

# Remove policy results and logs
rm -f policy_results.json
rm -f opa_output.json
rm -f coverage.json
find . -name "*.log" -delete

# Remove backup files  
find . -name "*.backup" -delete
find . -name "*.bak" -delete

# Remove temporary files
rm -rf test/temp/
rm -rf scripts/output/
rm -rf docs/temp/
```

### Git Repository Cleanup

```bash
# If you want to keep git history but clean working directory
git clean -fd  # Remove untracked files and directories
git reset --hard HEAD  # Reset to last commit

# If you want to remove git repository entirely
rm -rf .git/

# If repository is on GitHub and you want to delete it:
# 1. Go to GitHub repository settings
# 2. Scroll to "Danger Zone"
# 3. Click "Delete this repository"
# 4. Type repository name to confirm
```

---

## 4. 🛠️ Tools and Dependencies Removal

### Remove Installed Tools (Optional)

⚠️ **Warning**: Only remove tools if you won't use them for other projects.

```bash
# Remove OPA
sudo rm -f /usr/local/bin/opa

# Remove Terraform (if installed manually)
sudo rm -f /usr/local/bin/terraform

# Remove AWS CLI (if you don't need it)
sudo rm -rf /usr/local/aws-cli
sudo rm -f /usr/local/bin/aws
sudo rm -f /usr/local/bin/aws_completer

# Remove jq (if installed specifically for this project)
sudo apt remove jq
```

### Remove Package Sources

```bash
# Remove Terraform repository
sudo rm -f /etc/apt/sources.list.d/hashicorp.list
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Update package cache
sudo apt update
```

### Clean Package Cache

```bash
# Clean downloaded packages
sudo apt clean
sudo apt autoremove

# Remove orphaned packages
sudo apt autoclean
```

---

## 5. ⚙️ System Configuration Cleanup

### Environment Variables

```bash
# Remove AWS credentials (if set for this project only)
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION

# Remove from .bashrc if added there
sed -i '/AWS_ACCESS_KEY_ID/d' ~/.bashrc
sed -i '/AWS_SECRET_ACCESS_KEY/d' ~/.bashrc
sed -i '/AWS_DEFAULT_REGION/d' ~/.bashrc

# Remove custom aliases
sed -i '/alias lab=/d' ~/.bashrc
sed -i '/alias tf=/d' ~/.bashrc

# Reload bash configuration
source ~/.bashrc
```

### SSH Keys and Credentials

```bash
# Remove AWS credentials directory (if created for this project)
rm -rf ~/.aws/

# Remove any SSH keys created for this project
rm -f ~/.ssh/policy-lab-key
rm -f ~/.ssh/policy-lab-key.pub
```

### Command History (Optional)

```bash
# Clear bash history if it contains sensitive commands
history -c
history -w

# Or remove specific entries
history -d <line_number>
```

---

## 🔍 Verification Steps

### Confirm Complete Removal

```bash
# Verify tools are removed (should show "command not found")
terraform --version
opa version

# Verify no project files remain
ls -la ~/policy-lab  # Should not exist
ls -la "/mnt/c/Users/k.omo/Documents/GitHub.New/Policy Enforcement"  # Should not exist

# Verify no Terraform state files anywhere
find ~ -name "*.tfstate" 2>/dev/null
find /mnt/c -name "*.tfstate" 2>/dev/null

# Check for remaining AWS resources (if AWS CLI still installed)
aws s3 ls  # Should not show project buckets
aws ec2 describe-instances  # Should not show project instances
```

### Security Verification

```bash
# Ensure no credentials in shell history
history | grep -i aws
history | grep -i secret
history | grep -i key

# Check environment variables
env | grep -i aws
env | grep -i secret

# Verify no sensitive files remain
find ~ -name "*secret*" 2>/dev/null
find ~ -name "*password*" 2>/dev/null
find ~ -name "*.pem" 2>/dev/null
```

---

## 🚨 Troubleshooting Common Issues

### Infrastructure Won't Destroy

```bash
# Check for protection settings
terraform show | grep prevent_destroy

# Force destroy specific resources
terraform destroy -target=aws_s3_bucket.company_data

# Manual cleanup via AWS Console if needed
# 1. Log into AWS Console
# 2. Navigate to each service (S3, EC2, VPC)
# 3. Manually delete resources with project tags
```

### Permission Denied Errors

```bash
# Fix file permissions
chmod -R 755 ~/policy-lab/

# Use sudo for system files
sudo rm -f /usr/local/bin/opa

# Check file ownership
ls -la /usr/local/bin/opa
sudo chown $USER:$USER filename
```

### Files Still Exist After Removal

```bash
# Force removal
rm -rf ~/policy-lab/
sudo rm -rf ~/policy-lab/

# Check for hidden files
ls -la ~/
ls -la "/mnt/c/Users/k.omo/Documents/GitHub.New/"

# Use find to locate remaining files
find ~ -name "*policy*" 2>/dev/null
find ~ -name "*terraform*" 2>/dev/null
```

---

## ✅ Post-Teardown Checklist

After completing teardown, verify:

- [ ] **No AWS charges**: Check AWS billing dashboard for unexpected costs
- [ ] **Clean file system**: No project files remain in expected locations
- [ ] **Tools removed**: Commands return "not found" if tools were uninstalled
- [ ] **Credentials cleared**: No AWS credentials in environment or files
- [ ] **Documentation saved**: Important learnings and portfolio materials backed up
- [ ] **Git repositories**: Deleted from GitHub if no longer needed
- [ ] **System clean**: No orphaned processes or configurations

## 📋 Quick Teardown Script

For fast teardown, you can create this script:

```bash
#!/bin/bash
# quick-teardown.sh

echo "🧹 Starting Policy as Code Lab teardown..."

# Infrastructure
cd ~/policy-lab/terraform 2>/dev/null && terraform destroy -auto-approve

# Files
rm -rf ~/policy-lab/
rm -f ~/policy-lab

# Tools (uncomment if you want to remove them)
# sudo rm -f /usr/local/bin/opa
# sudo rm -f /usr/local/bin/terraform

echo "✅ Teardown complete!"
```

Make it executable and run:
```bash
chmod +x quick-teardown.sh
./quick-teardown.sh
```

---

## 🎯 Preservation Options

If you want to keep parts of the project:

### Save Portfolio Materials
```bash
# Create archive of important files
mkdir ~/policy-lab-portfolio
cp ~/policy-lab/docs/*.md ~/policy-lab-portfolio/
cp ~/policy-lab/policies/*.rego ~/policy-lab-portfolio/
tar -czf policy-lab-portfolio.tar.gz ~/policy-lab-portfolio/
```

### Keep Tools for Future Use
```bash
# Keep Terraform and OPA installed
# Only remove project files, not tools
rm -rf ~/policy-lab/
# Keep tools in /usr/local/bin/
```

### Archive Project
```bash
# Create full project archive before deletion
tar -czf policy-lab-archive.tar.gz ~/policy-lab/
mv policy-lab-archive.tar.gz ~/Documents/
rm -rf ~/policy-lab/
```

This completes the comprehensive teardown of your Policy as Code enforcement lab. The project can be safely removed while preserving any materials you want to keep for your portfolio or future reference.