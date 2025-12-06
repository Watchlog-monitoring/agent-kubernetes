# راهنمای به‌روزرسانی Helm Chart

## مراحل به‌روزرسانی Chart

### مرحله 1: تغییر Version در Chart.yaml

```bash
cd agent-kubernetes/helm/watchlog-agent
```

فایل `Chart.yaml` را باز کنید و version را افزایش دهید:

```yaml
apiVersion: v2
name: watchlog-agent
description: A Helm chart for Watchlog Kubernetes Agent
type: application
version: 1.0.1  # ← این را افزایش دهید (مثلاً 1.0.1, 1.1.0, 2.0.0)
appVersion: "1.3.0"  # ← اگر agent version تغییر کرد، این را هم به‌روزرسانی کنید
keywords:
  - monitoring
  - logging
  - kubernetes
  - watchlog
maintainers:
  - name: Watchlog Team
```

**قوانین Version:**
- **Patch** (1.0.0 → 1.0.1): تغییرات کوچک، bug fixes
- **Minor** (1.0.0 → 1.1.0): اضافه کردن features جدید (backward compatible)
- **Major** (1.0.0 → 2.0.0): تغییرات breaking (backward incompatible)

### مرحله 2: Package کردن Chart

```bash
cd agent-kubernetes/helm
helm package watchlog-agent --destination /tmp/
```

این دستور یک فایل جدید ایجاد می‌کند: `watchlog-agent-1.0.1.tgz` (با version جدید)

### مرحله 3: کپی کردن به Repository

```bash
# کپی کردن chart جدید به repository
cp /tmp/watchlog-agent-*.tgz watchlog-helm-charts/
```

یا اگر repository را clone کرده‌اید:

```bash
cd watchlog-helm-charts
cp /tmp/watchlog-agent-*.tgz .
```

### مرحله 4: به‌روزرسانی index.yaml

```bash
cd watchlog-helm-charts

# به‌روزرسانی index (merge با index موجود)
helm repo index . --url https://watchlog-monitoring.github.io/watchlog-helm-charts --merge index.yaml
```

این دستور:
- Chart جدید را به `index.yaml` اضافه می‌کند
- Chart قدیمی را نگه می‌دارد (برای backward compatibility)
- URL ها را درست تنظیم می‌کند

### مرحله 5: بررسی تغییرات

```bash
# بررسی index.yaml
cat index.yaml

# باید هر دو version را ببینید:
# - watchlog-agent-1.0.0.tgz (قدیمی)
# - watchlog-agent-1.0.1.tgz (جدید)
```

### مرحله 6: Commit و Push

```bash
git add .
git commit -m "Update chart to version 1.0.1"
git push
```

## مثال کامل

فرض کنید می‌خواهید chart را از `1.0.0` به `1.0.1` به‌روزرسانی کنید:

```bash
# 1. Version را تغییر دهید
cd agent-kubernetes/helm/watchlog-agent
# Chart.yaml را ویرایش کنید: version: 1.0.1

# 2. Package کنید
cd ..
helm package watchlog-agent --destination /tmp/

# 3. به repository کپی کنید
cd ../watchlog-helm-charts
cp /tmp/watchlog-agent-1.0.1.tgz .

# 4. Index را به‌روزرسانی کنید
helm repo index . --url https://watchlog-monitoring.github.io/watchlog-helm-charts --merge index.yaml

# 5. بررسی کنید
cat index.yaml | grep "version:"

# 6. Commit و push
git add .
git commit -m "Update chart to version 1.0.1"
git push
```

## Script خودکار

می‌توانید یک script بسازید:

```bash
#!/bin/bash
# update-chart.sh

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: ./update-chart.sh <version>"
    echo "Example: ./update-chart.sh 1.0.1"
    exit 1
fi

echo "📦 Updating chart to version $VERSION..."

# 1. Update Chart.yaml
cd agent-kubernetes/helm/watchlog-agent
sed -i '' "s/^version:.*/version: $VERSION/" Chart.yaml
echo "✅ Chart.yaml updated"

# 2. Package
cd ..
helm package watchlog-agent --destination /tmp/
echo "✅ Chart packaged"

# 3. Copy to repository
cd ../watchlog-helm-charts
cp /tmp/watchlog-agent-${VERSION}.tgz .
echo "✅ Chart copied to repository"

# 4. Update index
helm repo index . --url https://watchlog-monitoring.github.io/watchlog-helm-charts --merge index.yaml
echo "✅ Index updated"

# 5. Show status
echo ""
echo "📋 Changes:"
git status --short

echo ""
echo "🚀 Next steps:"
echo "  cd watchlog-helm-charts"
echo "  git add ."
echo "  git commit -m 'Update chart to version $VERSION'"
echo "  git push"
```

استفاده:
```bash
chmod +x update-chart.sh
./update-chart.sh 1.0.1
```

## تست بعد از به‌روزرسانی

بعد از push، کاربران می‌توانند به‌روزرسانی کنند:

```bash
# Update repository
helm repo update

# جستجو (باید version جدید را ببینید)
helm search repo watchlog --versions

# نصب version جدید
helm upgrade watchlog-agent watchlog/watchlog-agent \
  --namespace monitoring \
  --reuse-values \
  --version 1.0.1
```

## نکات مهم

1. **همیشه version را افزایش دهید** - Helm نمی‌تواند chart با version یکسان را replace کند
2. **Chart قدیمی را نگه دارید** - برای backward compatibility
3. **appVersion را به‌روزرسانی کنید** - اگر agent version تغییر کرد
4. **تست کنید** - قبل از push، chart را تست کنید:
   ```bash
   helm install test-release /tmp/watchlog-agent-1.0.1.tgz --dry-run --debug
   ```

