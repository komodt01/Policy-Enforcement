# Linux Commands Reference

## 📋 Complete Command Reference for Policy as Code Project

This document contains all Linux/WSL commands used throughout the Policy as Code enforcement lab, organized by phase and functionality.

## 🚀 Environment Setup Commands

### Project Structure Creation
```bash
# Create main project directory
mkdir policy-enforcement-lab
cd policy-enforcement-lab

# Create subdirectories
mkdir -p {manual-review,terraform-examples,documentation,scripts,policies,test,.github/workflows}

# Verify structure
ls -la
tree  # If tree is installed
```

### Tool Installation (Ubuntu/WSL)
```bash
# Update package manager
sudo apt update

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Install OPA
curl -L -o opa https://github.com/open-policy-agent/opa/releases/download/v0.57.0/opa_linux_amd64_static
chmod +x opa
sudo mv opa /usr/local/bin/

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Install jq for JSON processing
sudo apt install jq

# Verify installations
terraform --version
opa version
aws --version
jq --version
```

### WSL File System Navigation
```bash
# Navigate to Windows directory from WSL
cd /mnt/c/Users/k.omo/Documents/GitHub.New/Policy\ Enforcement/

# Create symbolic link for easy access
ln -s "/mnt/c/Users/k.omo/Documents/GitHub.New/Policy Enforcement" ~/policy-lab

# Navigate using symbolic link
cd ~/policy-lab

# Check current directory
pwd

# List files with permissions
ls -la
```

## 🗃️ File Management Commands

### Creating Configuration Files
```bash
# Create Terraform main configuration
cat > main.tf << 'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "test" {
  byte_length = 4
}
EOF

# Create violating S3 example
cat > violating-s3.tf << 'EOF'
resource "aws_s3_bucket" "company_data" {
  bucket = "company-sensitive-data"
  acl    = "public-read"
  
  tags = {
    Name = "data-bucket"
  }
}
EOF

# Create OPA S3 security policy
cat > policies/s3-security.rego << 'EOF'
package terraform.s3

deny[msg] {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "aws_s3_bucket"
    resource.values.acl == "public-read"
    msg := sprintf("❌ CRITICAL: S3 bucket '%s' cannot have public-read ACL", [resource.address])
}
EOF
```

### File Operations
```bash
# View file contents
cat filename.tf
less filename.tf  # For pagination
head -n 20 filename.tf  # First 20 lines
tail -n 10 filename.tf  # Last 10 lines

# Copy files
cp source.tf destination.tf
cp -r source_directory/ destination_directory/

# Move/rename files
mv old_name.tf new_name.tf
mv file.tf directory/

# Remove files
rm filename.tf
rm -f filename.tf  # Force remove
rm -rf directory/  # Remove directory recursively

# Backup files
mv compliant-s3.tf compliant-s3.tf.backup
mv violating-database.tf violating-database.tf.backup
```

### File Permissions
```bash
# Make scripts executable
chmod +x scripts/setup.sh
chmod +x scripts/test-local.sh
chmod +x scripts/cleanup.sh

# Set specific permissions
chmod 755 script.sh  # rwxr-xr-x
chmod 644 file.txt   # rw-r--r--

# Check permissions
ls -la file.txt
stat file.txt
```

## 🏗️ Terraform Commands

### Basic Terraform Operations
```bash
# Initialize Terraform (download providers)
terraform init

# Validate configuration syntax
terraform validate

# Format Terraform files
terraform fmt
terraform fmt -check  # Check without modifying

# Plan infrastructure changes
terraform plan

# Apply changes (with confirmation)
terraform apply

# Apply without confirmation
terraform apply -auto-approve

# Destroy infrastructure
terraform destroy
terraform destroy -auto-approve
```

### Terraform Plan Operations
```bash
# Save plan to file
terraform plan -out=tfplan

# Show saved plan
terraform show tfplan

# Convert plan to JSON for OPA
terraform show -json tfplan > plan.json

# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show aws_s3_bucket.company_data
```

### Terraform Troubleshooting
```bash
# Refresh state
terraform refresh

# Import existing resource
terraform import aws_s3_bucket.example bucket-name

# Remove resource from state
terraform state rm aws_s3_bucket.example

# Replace corrupted resource
terraform apply -replace=aws_s3_bucket.example

# Enable debug logging
export TF_LOG=DEBUG
terraform plan
```

## 🔒 OPA Policy Commands

### Basic OPA Operations
```bash
# Evaluate single policy file
opa eval --data policies/s3-security.rego --input plan.json "data.terraform.s3.deny[x]" --format pretty

# Evaluate multiple policies
opa eval --data policies/ --input plan.json \
  "data.terraform.s3.deny[x]; data.terraform.tagging.deny[x]" \
  --format pretty

# Output as JSON
opa eval --data policies/ --input plan.json \
  "data.terraform.s3.deny[x]" \
  --format json

# Run policy tests
opa test policies/ test/

# Format Rego files
opa fmt policies/
opa fmt --diff policies/  # Show differences
```

### Policy Development Commands
```bash
# Start OPA REPL for interactive development
opa run policies/

# Validate Rego syntax
opa fmt --diff policies/s3-security.rego

# Test specific policy
opa test policies/s3-security.rego

# Evaluate with verbose output
opa eval --data policies/ --input plan.json "data" --format pretty

# Check policy coverage
opa test --coverage policies/ test/
```

### Policy Testing Commands
```bash
# Run all tests with verbose output
opa test policies/ test/ -v

# Run specific test file
opa test policies/s3-security.rego test/s3-tests.rego

# Benchmark policy performance
opa test --bench policies/ test/

# Generate test coverage report
opa test --coverage --format=json policies/ test/ > coverage.json
```

## 📊 JSON Processing Commands

### Using jq for Data Manipulation
```bash
# Pretty print JSON
jq '.' plan.json

# Extract specific fields
jq '.planned_values.root_module.resources[] | .type' plan.json

# Filter S3 resources
jq '.planned_values.root_module.resources[] | select(.type == "aws_s3_bucket")' plan.json

# Extract S3 tags
jq '.planned_values.root_module.resources[] | select(.type == "aws_s3_bucket") | .values.tags' plan.json

# Count resources by type
jq '.planned_values.root_module.resources | group_by(.type) | map({type: .[0].type, count: length})' plan.json

# Extract resource addresses
jq -r '.planned_values.root_module.resources[] | .address' plan.json
```

### JSON Validation and Processing
```bash
# Validate JSON syntax
jq empty plan.json && echo "Valid JSON" || echo "Invalid JSON"

# Compact JSON output
jq -c '.' plan.json

# Extract specific values
jq -r '.planned_values.root_module.resources[] | select(.type == "aws_s3_bucket") | .values.bucket' plan.json

# Create summary report
jq '{
  total_resources: (.planned_values.root_module.resources | length),
  s3_buckets: [.planned_values.root_module.resources[] | select(.type == "aws_s3_bucket") | .address],
  resource_types: [.planned_values.root_module.resources[] | .type] | unique
}' plan.json
```

## 🧪 Testing and Validation Commands

### Manual Review Process
```bash
# Time manual review
echo "Manual review started: $(date)"
cat violating-s3.tf
echo "Manual review completed: $(date)"

# Document findings
echo "Violations found: 5" >> review-log.txt
echo "Risk level: CRITICAL" >> review-log.txt
echo "Recommendation: Do not deploy" >> review-log.txt
```

### Automated Testing
```bash
# Run local policy tests
./scripts/test-local.sh

# Test specific components
./scripts/test-local.sh --syntax     # Validate Rego syntax
./scripts/test-local.sh --plans      # Test against sample plans
./scripts/test-local.sh --benchmark  # Performance testing

# Benchmark policy evaluation
time opa eval --data policies/ --input plan.json "data.terraform.s3.deny[x]; data.terraform.tagging.deny[x]" --format json
```

### Performance Monitoring
```bash
# Monitor file sizes
du -sh policies/
du -sh terraform/
du -sh test/

# Check system resources
free -h        # Memory usage
df -h          # Disk usage
top            # Process monitoring
htop           # Interactive process viewer
```

## 🔄 Git Commands

### Repository Management
```bash
# Initialize repository
git init

# Configure Git (if not done globally)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Handle line endings for WSL
git config core.autocrlf input
git config core.eol lf

# Add files to staging
git add .
git add specific-file.tf
git add policies/

# Commit changes
git commit -m "Initial Policy as Code implementation"
git commit -m "Add S3 security and tagging policies"

# Create and switch branches
git checkout -b feature/encryption-policies
git branch                    # List branches
git checkout main            # Switch to main branch

# Merge branches
git merge feature/encryption-policies

# View history
git log --oneline
git log --graph --oneline --all
```

### Remote Repository Operations
```bash
# Add remote origin
git remote add origin https://github.com/username/policy-enforcement-lab.git

# Push to remote
git push -u origin main
git push origin feature/new-policies

# Pull from remote
git pull origin main

# Clone repository
git clone https://github.com/username/policy-enforcement-lab.git
```

## 🧹 Cleanup Commands

### File Cleanup
```bash
# Remove Terraform files
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -f .terraform.lock.hcl
rm -f tfplan
rm -f plan.json
rm -rf .terraform/

# Remove backup files
rm -f *.backup
find . -name "*.backup" -delete

# Clean up test artifacts
rm -f policy_results.json
rm -f opa_output.json
rm -f coverage.json
```

### System Cleanup
```bash
# Clear command history (optional)
history -c

# Remove temporary files
rm -rf /tmp/opa-*
rm -rf /tmp/terraform-*

# Clean package cache (Ubuntu)
sudo apt clean
sudo apt autoremove
```

## 📈 Monitoring and Logging Commands

### Process Monitoring
```bash
# Monitor OPA processes
ps aux | grep opa

# Monitor Terraform processes
ps aux | grep terraform

# Check port usage
netstat -tulpn | grep :8181  # Default OPA port
lsof -i :8181
```

### Log Analysis
```bash
# View system logs
journalctl -f              # Follow system journal
tail -f /var/log/syslog    # Follow system log

# Create custom logs
echo "$(date): Policy evaluation started" >> /var/log/policy.log
echo "$(date): Found 7 violations" >> /var/log/policy.log
```

### Performance Measurement
```bash
# Time command execution
time terraform plan
time opa eval --data policies/ --input plan.json "data.terraform.s3.deny[x]"

# Measure memory usage
/usr/bin/time -v opa eval --data policies/ --input plan.json "data.terraform.s3.deny[x]"

# Monitor disk I/O
iostat 1 5    # If sysstat package is installed
iotop         # If iotop is installed
```

---

## 💡 Command Tips and Best Practices

### Useful Aliases
```bash
# Add to ~/.bashrc for convenience
alias lab="cd ~/policy-lab"
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias opa-eval='opa eval --data policies/ --input plan.json'

# Reload aliases
source ~/.bashrc
```

### Safety Commands
```bash
# Always check before destructive operations
terraform plan -destroy  # Before terraform destroy
ls -la                   # Before rm commands
git status               # Before git operations
```

### Troubleshooting Commands
```bash
# Check file permissions
ls -la filename

# Verify PATH
echo $PATH
which terraform
which opa

# Check environment variables
env | grep -i aws
env | grep -i terraform

# Test connectivity
ping google.com
curl -I https://registry.terraform.io
```

This comprehensive command reference covers all Linux/WSL operations used in the Policy as Code enforcement lab, from initial setup through testing and cleanup.