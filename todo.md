Todo:
- Document how to set up networking for the uVM
- Document which minimum flags are actually needed for the jailer
- Document how the linux kernel file is built. Currently using the 5.10 file gleaned from the bucket.
- Create script for getting the linux kernel and rootfs files
- Create shell script to tie together the commands to start/stop a uVM with the jailer
- Investigate how fly.io and ECS/Lambda work to get ideas on how to structure the API

Done:
- Document steps to start a uVM
- Document steps to stop a uVM
- Figure out how to run uVM's using the jailer
- Figure out creating and removing uVM's by interacting with the socket API, creating the necessary files and working with the jailer.
