# k8s-swap-cgroup
Simple sidecar to enable swap on container

Configuration:
```
SWAP_PCT: 0.7 # 70% high water mark
```

To enable push as priveledged side car with sysfs mount