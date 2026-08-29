#!/bin/bash
# check-kernel.sh - Cek kompatibilitas kernel untuk Kontainer_boot
# Jalankan sebelum launcher.sh

echo "=== Kontainer_boot: Kernel Compatibility Check ==="
echo ""

PASS=0
FAIL=0
WARN=0
FAILED_ITEMS=()
WARNED_ITEMS=()

check_config() {
    local name="$1"
    local desc="$2"
    local result=""

    if [ -f "/proc/config.gz" ]; then
        result=$(zcat /proc/config.gz 2>/dev/null | grep "^${name}=")
    elif [ -f "/boot/config-$(uname -r)" ]; then
        result=$(grep "^${name}=" "/boot/config-$(uname -r)" 2>/dev/null)
    fi

    if echo "$result" | grep -q "=y"; then
        echo "[ OK ] $name ($desc)"
        PASS=$((PASS+1))
    elif echo "$result" | grep -q "=m"; then
        echo "[ OK ] $name ($desc) - built as module"
        PASS=$((PASS+1))
    else
        echo "[FAIL] $name ($desc) - not found/enabled"
        FAIL=$((FAIL+1))
        FAILED_ITEMS+=("$name ($desc)")
    fi
}

check_runtime() {
    local path="$1"
    local desc="$2"
    if [ -e "$path" ]; then
        echo "[ OK ] $path ($desc)"
        PASS=$((PASS+1))
    else
        echo "[WARN] $path ($desc) - not present"
        WARN=$((WARN+1))
        WARNED_ITEMS+=("$path ($desc)")
    fi
}

echo "--- Kernel config (required) ---"
check_config "CONFIG_NAMESPACES" "namespace support"
check_config "CONFIG_PID_NS" "PID namespace"
check_config "CONFIG_NET_NS" "network namespace"
check_config "CONFIG_UTS_NS" "UTS namespace"
check_config "CONFIG_IPC_NS" "IPC namespace"
check_config "CONFIG_CGROUPS" "cgroups"
check_config "CONFIG_CGROUP_SCHED" "cgroup scheduler"
check_config "CONFIG_CGROUP_FREEZER" "cgroup freezer"
check_config "CONFIG_DEVPTS_MULTIPLE_INSTANCES" "multiple devpts instances"

echo ""
echo "--- Kernel config (optional) ---"
check_config "CONFIG_HUGETLBFS" "hugepages (non-fatal if missing)"

echo ""
echo "--- Runtime checks ---"
check_runtime "/sys/fs/cgroup/cgroup.subtree_control" "cgroup v2 subtree control"
check_runtime "/proc/self/ns/pid" "PID ns active"
check_runtime "/proc/self/ns/net" "net ns active"

echo ""
echo "=== Summary ==="
echo "Pass: $PASS | Warn: $WARN | Fail: $FAIL"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Item yang GAGAL:"
    for item in "${FAILED_ITEMS[@]}"; do
        echo "  - $item"
    done
fi

if [ "$WARN" -gt 0 ]; then
    echo ""
    echo "Item yang WARNING:"
    for item in "${WARNED_ITEMS[@]}"; do
        echo "  - $item"
    done
fi

echo ""

if [ "$FAIL" -eq 0 ]; then
    echo "Kernel Anda kompatibel. Aman lanjut ke launcher.sh."
    exit 0
elif [ "$FAIL" -le 2 ]; then
    echo "Ada beberapa fitur kurang. Container mungkin tetap jalan tapi terbatas."
    echo "Cek apakah device Anda pakai custom kernel (KernelSU/dll)."
    exit 1
else
    echo "Kernel tidak mendukung sebagian besar fitur wajib."
    echo "Kemungkinan besar butuh custom kernel dengan namespace + cgroup support."
    echo "Tambal manual ke kernel stock TIDAK disarankan/realistis."
    exit 2
fi
