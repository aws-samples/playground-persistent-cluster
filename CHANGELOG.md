# Change Logs

## Commit \#dbfc93d

Against [adt#76f9956](https://github.com/aws-samples/awsome-distributed-training/tree/76f995674b1c2e07e25814b15262baac8abc2bcd)

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
  - an [example](#36-create-a-new-aws-managed-microsoft-ad-with-ldaps-endpoint) to setup an LDAPS
      endpoint. Ignore this when you have an existing LDAPS.
  - an [LCC script](src/LifecycleScripts/base-config/setup_sssd4ldaps.sh) to get a cluster connect
      to an LDAPS endpoint.
- utility scripts for SMHP client ([bin/](bin/))
- utility scripts for the cluster ([src/sample-slurm-jobs/](/src/sample-slurm-jobs/)): trigger
   unhealthy instance and auto-resume Slurm step, probe ami, etc.
- other opinionated changes to shell and environment. Feel free to customize the
   [initsmhp](src/LifecycleScripts/base-config/initsmhp.sh) scripts.
