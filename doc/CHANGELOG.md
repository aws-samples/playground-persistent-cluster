# History

## Tag v2403.01

### Differences against [adt#39ca357](https://github.com/aws-samples/awsome-distributed-training/tree/39ca357f7a3df841ffd1232221cd12afcf791c30)

- hardened `setup_mariadb_accounting.sh`.
- enable [time synchronization](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html)
   to prevent torchrun crashes
   ([details](https://github.com/pytorch/pytorch/issues/76287#issuecomment-1958685480)).
- allow ssh to compute nodes without host keys.
- enable [enroot containers](https://github.com/NVIDIA/enroot), but disable the CLIs for non-root
  users on login and controller nodes which may have insufficient root volume for container
  operations. Non-root users must perform container operations (e.g., build images) on compute nodes
  with NVMe.
- enable multi-users via LDAPS. Note that're two independent parts:
  - an [example](../README#36-create-a-new-aws-managed-microsoft-ad-with-ldaps-endpoint) to setup an
    LDAPS endpoint. Ignore this when you have an existing LDAPS.
  - an [LCC script](../src/LifecycleScripts/base-config/setup_sssd4ldaps.sh) to get a cluster
    connect to an LDAPS endpoint.
- disable and mask [GDM (GNOME Display
  Manager)](https://en.wikipedia.org/wiki/GNOME_Display_Manager).
- utility scripts for SMHP client ([bin/](../bin/))
- utility scripts for the cluster ([src/sample-slurm-jobs/](../src/sample-slurm-jobs/)): trigger
   unhealthy instance and auto-resume Slurm step, probe ami, etc.
- other opinionated changes to shell and environment. Feel free to customize the
   [initsmhp](../src/LifecycleScripts/base-config/initsmhp.sh) scripts.

### Changelogs

- new `bin/` utilities: `cluster-log.sh`, `cluster-nodes.sh`, `cluster-status.sh`, `show-az.sh`.
  - `cluster-status.sh` can export the JSON payload returned by `aws sagemaker
    describe-cluster ...` into the JSON format for `cluster-config.json`. Useful to regenerate a
    `cluster-config.json` for another deployment.
  - `cluster-log.sh` supports watch mode and one-time mode. The watch mode implements retry logic to
    wait for LCC logs to appear in your Cloudwatch log streams.
- backported `adt` scripts that relocate home directories to `/fsx` (PR [#12](https://github.com/aws-samples/playground-persistent-cluster/pull/12)).
- upstreamed time synchronization to `adt` (PR aws-samples/awsome-distributed-training#172).
- upstreamed Slurm-daemons masking to `adt` (PR aws-samples/awsome-distributed-training#169).
- backported `adt` scripts that setup Prometheus + Grafana (PR [#16](https://github.com/aws-samples/playground-persistent-cluster/pull/16)).
- upstreamed sacct-on-login-nodes (PR [#10](https://github.com/aws-samples/playground-persistent-cluster/pull/10)) to `adt` (PR
  aws-samples/awsome-distributed-training#164).

## Commit \#dbfc93d

### Differences against [adt#76f9956](https://github.com/aws-samples/awsome-distributed-training/tree/76f995674b1c2e07e25814b15262baac8abc2bcd)

- require an FSx Lustre, and mount it on `/fsx`
- home directories on shared file system
  - `ubuntu`: relocate home directory to `/fsx/ubuntu`, and generate a new ssh keypair for if it
      doesn't exist on `/fsx/ubuntu/.ssh`
  - Other users: set home directories to `/fsx/home/<USERNAME>`
- hardened `setup_mariadb_accounting.sh`.
- enable [time synchronization](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html)
   to prevent torchrun crashes
   ([details](https://github.com/pytorch/pytorch/issues/76287#issuecomment-1958685480)).
- mask unnecessary Slurm daemons
  - mask `slurmd` on controller node
  - mask `slurmctld` on compute nodes and login nodes.
- allow ssh to compute nodes without host keys.
- enable [enroot containers](https://github.com/NVIDIA/enroot). At this moment, please perform
   container operations (including building images) on compute nodes with NVMe. Avoid using the
   controller or login nodes for such purposes, as their low root volume size could easily cause
   them to freeze, rendering them (and potentially the whole cluster) unusable.
- enable multi-users via LDAPS. Note that're two independent parts:
  - an [example](../README#36-create-a-new-aws-managed-microsoft-ad-with-ldaps-endpoint) to setup an
      LDAPS endpoint. Ignore this when you have an existing LDAPS.
  - an [LCC script](../src/LifecycleScripts/base-config/setup_sssd4ldaps.sh) to get a cluster
      connect to an LDAPS endpoint.
- utility scripts for SMHP client ([bin/](../bin))
- utility scripts for the cluster ([src/sample-slurm-jobs/](/src/sample-slurm-jobs/)): trigger
   unhealthy instance and auto-resume Slurm step, probe ami, etc.
- other opinionated changes to shell and environment. Feel free to customize the
   [initsmhp](../src/LifecycleScripts/base-config/initsmhp.sh) scripts.
