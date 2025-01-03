# Background writer

Q
> If you believe these statistics, then the background process (bgwriter) does not clear the RAM from dirty buffers, unlike the checkpoint. Should I be worried about this?

A
> No, that is exactly what it is supposed to be doing. Most of the buffers get cleaned (written out to disk) by the checkpointer. But without the background writer, it could happen that between checkpoints all or almost all shared buffers become dirty

https://stackoverflow.com/questions/78840401/cleaning-dirty-buffers-with-a-background-process-bgwriter-in-postgres


