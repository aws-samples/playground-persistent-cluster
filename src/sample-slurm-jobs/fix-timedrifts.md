Consistent times across cluster is crucial for distributed workload. For example, torchrun fails to
launch when it detects 5 seconds (or more) time differences among workers.

Check the time of all compute nodes as follows:

```bash
# On controller node. Replace number of nodes (-N xxx) as needed.
srun -N 2 bash -c 'echo "$(hostname): $(date)"' | sort -k2,3
```

When time drifts reported, follow these corrective procedure on all compute nodes
([reference](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html)).

```bash
# Do below steps as root
sed -i sed \
    '/\# See http:\/\/www.pool.ntp.org\/join.html for more information./a server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4\npool time.aws.com iburst' \
    /etc/chrony/chrony.conf

systemctl enable --now chrony
/etc/init.d/chrony restart
```

Credits: Ben Snyder, Sean Smith, Shubham Arora
