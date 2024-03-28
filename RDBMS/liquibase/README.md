# Liquibase

TLDR: checksums
- can change between versions, and are updated silently ;
- are version and content specific ;
- are not order-specific .


## Same changelog, different versions

```postgresql
SELECT md5sum FROM databasechangelog;
```

```shell
~/bin/liquibase/4.18/liquibase drop-all
~/bin/liquibase/4.18/liquibase update
```

Starts by `8` in 4.18
```shell
8:da2735d71421f4820b3d3f047e431a07
```

```shell
~/bin/liquibase/4.27/liquibase drop-all
~/bin/liquibase/4.27/liquibase update
```

Starts by `9` in 4.27
```shell
9:872e38a35e90b79974917f2cef5fa8f8
```

## On consecutive version:

Version 4.18
``` shell
8:243572277b0954cd1e3bc398774a4eeb
8:87a4a94f9726c884720cea2e9bbe9ae6
8:0c4d8b0608f9c9a4a84a603dd6cb026a
```

Then `~/bin/liquibase/4.27/liquibase update` 
```shell
9:4438713e733b6cc887efa563883ee884
9:efe606e53d386cb82132428d18c9c17a
9:1a7505d02426b95c15ea78ac70eefd4f
```

Checksums are updated !

`DEBUG` logs mentions upgrading
```shell
Upgrading checksum for Changeset changelogs/third.yml::3::foo from 8:87a4a94f9726c884720cea2e9bbe9ae6 to 9:1a7505d02426b95c15ea78ac70eefd4f.
[2024-03-28 20:20:13] INFO [liquibase.ui] Upgrading checksum for Changeset changelogs/third.yml::3::foo from 8:87a4a94f9726c884720cea2e9bbe9ae6 to 9:1a7505d02426b95c15ea78ac70eefd4f.
[2024-03-28 20:20:13] FINE [liquibase.executor] UPDATE public.databasechangelog SET MD5SUM = '9:1a7505d02426b95c15ea78ac70eefd4f' WHERE ID = '3' AND AUTHOR = 'foo' AND FILENAME = 'changelogs/third.yml'
[2024-03-28 20:20:13] FINE [liquibase.executor] 1 row(s) affected
```

## Two changelogs at once, or one at a time

Same !

```shell
8:243572277b0954cd1e3bc398774a4eeb
8:0c4d8b0608f9c9a4a84a603dd6cb026a
```

## If a changelog get inserted between two

Checksum are the same, they just get inserted differently

All at once

```shell
8:243572277b0954cd1e3bc398774a4eeb
8:0c4d8b0608f9c9a4a84a603dd6cb026a
8:87a4a94f9726c884720cea2e9bbe9ae6
```

The first and last

```shell
8:243572277b0954cd1e3bc398774a4eeb
8:87a4a94f9726c884720cea2e9bbe9ae6
```

And then the one in the middle (commenting first and last)

```shell
8:243572277b0954cd1e3bc398774a4eeb
8:87a4a94f9726c884720cea2e9bbe9ae6
8:0c4d8b0608f9c9a4a84a603dd6cb026a
```

And then uncommenting first and last: all OK