```console
[ubuntu@ip-10-1-141-163:~] $ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
dev*         up   infinite      2   idle ip-10-1-184-86,ip-10-1-232-95

[ubuntu@ip-10-1-141-163:~] $ srun --nodelist=ip-10-1-232-95 ./inject-dcgm-errors.sh 

[ubuntu@ip-10-1-141-163:~] $ sbatch -N2 --nodelist=ip-10-1-184-86,ip-10-1-232-95 always-failed-job.sbatch 
Submitted batch job 5

[ubuntu@ip-10-1-141-163:~] $ tail -f slurm-5.out 
|        ID   ID                                                             Usage      |
|=======================================================================================|
|  No running processes found                                                           |
+---------------------------------------------------------------------------------------+
[Auto Resume] Error: JobID: 5 StepID: 0 TaskID: 0 Task failed on node ip-10-1-184-86
[Auto Resume] Info: JobID: 5 StepID: 0 TaskID: 0 Successfully terminated the step since task exited with status: 65280 
srun: Job step aborted: Waiting up to 32 seconds for job step to finish.
srun: error: ip-10-1-184-86: task 0: Exited with exit code 255
srun: error: ip-10-1-232-95: task 1: Killed
[Auto Resume] Info: JobID: 5 StepID: 0 Initiating communication with cluster agent to diagnose health of nodes
[Auto Resume] Info: JobID: 5 StepID: 0 Response from cluster agent: JobId=5, ResumeAction=RETRYSTEP
[Auto Resume] Info: JobID: 5 StepID: 0 Job failed - replacing nodes
[Auto Resume] Info: JobID: 5 StepID: 0 Job failed - Droping unhealthy nodes
[Auto Resume] Info: JobID: 5 StepID: 0 Succesfully shrink job to retain healthy nodes ip-10-1-184-86
srun: job 6 queued and waiting for resources
<WAIT_FOR_A_WHILE>

# Below can be on a separate terminal
[ubuntu@ip-10-1-141-163:~] $ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
dev*         up   infinite      1  fail* ip-10-1-232-95
dev*         up   infinite      1  alloc ip-10-1-184-86

[ubuntu@ip-10-1-141-163:~] $ scontrol show node ip-10-1-232-95
NodeName=ip-10-1-232-95 Arch=x86_64 CoresPerSocket=48 
   CPUAlloc=0 CPUEfctv=192 CPUTot=192 CPULoad=0.71
   AvailableFeatures=(null)
   ActiveFeatures=(null)
   Gres=(null)
   NodeAddr=10.1.232.95 NodeHostName=ip-10-1-232-95 Version=23.02.3
   OS=Linux 5.15.0-1047-aws #52~20.04.1-Ubuntu SMP Thu Sep 21 10:05:54 UTC 2023 
   RealMemory=2097152 AllocMem=0 FreeMem=1997049 Sockets=2 Boards=1
   State=DOWN+CLOUD+FAIL+NOT_RESPONDING ThreadsPerCore=2 TmpDisk=0 Weight=1 Owner=N/A MCS_label=N/A
   Partitions=dev 
   BootTime=2024-02-21T01:20:42 SlurmdStartTime=2024-02-21T01:31:17
   LastBusyTime=2024-02-21T01:45:45 ResumeAfterTime=None
   CfgTRES=cpu=192,mem=2T,billing=192
   AllocTRES=
   CapWatts=n/a
   CurrentWatts=0 AveWatts=0
   ExtSensorsJoules=n/s ExtSensorsWatts=0 ExtSensorsTemp=n/s
   Reason=Action:Replace : Not responding [slurm@2024-02-21T01:53:15]
```
