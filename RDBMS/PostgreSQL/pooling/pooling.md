# Pooling

## Server-side

### pgPool

pgpool:
- start N process
- which can hold each M connexion

num_init_children = N
max_pool = M

So if you want 10 connexions, you can use
- N=10 / M=1
- N=1 / M=10

https://severalnines.com/blog/guide-pgpool-postgresql-part-one/

https://www.refurbed.org/posts/load-balancing-sql-queries-using-pgpool/


```shell
while :; do docker stats --no-stream | grep primary | awk '{print $4}' | sed -e 's/MiB//g' \
    | LC_ALL=en_US numfmt --from-unit Mi --to-unit Mi; sleep 1; done | ttyplot -u Mi
```











### Client-side

#### Tarn

https://github.com/vincit/tarn.js/
