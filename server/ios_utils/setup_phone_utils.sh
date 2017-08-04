#! /bin/bash

# Expects to be run from the root directory of varys.
#
# ARGS:
#   1) IP of iPhone
#   2) Path to public iPhone ssh key
#   3) Path to iPhone ssh private key
#
# EXAMPLE:
#   server/ios_utils/setup_phone_utils.sh '192.168.2.21' /Users/benjaminliu/Downloads/varys_iphone.pub /Users/benjaminliu/.ssh/varys_iphone


# Step 1: Setup SSH (password: alpine)

ssh root@$1 'passwd'
ssh root@$1 'mkdir /var/root/.ssh'
cat $2 | ssh root@$1 "cat > /var/root/.ssh/authorized_keys"
ssh root@$1 -i $3 'chmod 700 ~/.ssh'
ssh root@$1 -i $3 'chmod 600 ~/.ssh/authorized_keys'

# # Step 2: Setup SCP 

tar xvf server/ios_utils/jailbreak_utils.tgz -C /tmp usr/bin/scp
cat /tmp/usr/bin/scp | ssh -i $3 root@$1 "cat > scp"
ssh -i $3 root@$1 'chmod a+x /var/root/scp'
ssh -i $3 root@$1 'mv /var/root/scp /usr/bin'

# Step 3: Setup iosbinpack

scp -i $3 server/ios_utils/jailbreak_utils.tgz root@$1:/
ssh -i $3 root@$1 'cd / && tar xvfk /jailbreak_utils.tgz'
ssh -i $3 root@$1 'rm /jailbreak_utils.tgz'
ssh -i $3 root@$1 'ln -s /sbin/ping /usr/bin/ping'

# Step 4: SSH the decrypt libs
scp -i $3 ./server/ios_utils/dumpdecrypted_10_2.dylib root@$1:~/dumpdecrypted.dylib
scp -i $3 ./server/ios_utils/move_decrypted.sh root@$1:~/
