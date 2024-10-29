#!/bin/bash
cd
mkdir -p hands-on-01/inventory
cd hands-on-01
cat << EOF > inventory/hosts
[client_node]
192.168.20.4

[client_node:vars]
ansible_ssh_user=ec2-user
ansible_ssh_private_key_file=/home/ec2-user/.ssh/kk-key.pem
EOF

cd ~/hands-on-01
cat << EOF > site.yml
---
- hosts: client_node
  become: True
  roles:
    - hands-on
EOF


cd ~/hands-on-01
mkdir -p roles/hands-on/tasks
cat << EOF > roles/hands-on/tasks/main.yml
---
- name: create user
  user:
    name: test
    createhome: yes
    state: present
    password: "{{ 'test' | password_hash('sha512') }}"

- name: modify sshd_config
  lineinfile:
    dest: /etc/ssh/sshd_config
    state: present
    backrefs: yes
    regexp: '^PasswordAuthentication no'
    line: 'PasswordAuthentication yes'
    backup: yes
  notify:
    - restart sshd
EOF

cd ~/hands-on-01
mkdir -p roles/hands-on/handlers
cat << EOF > roles/hands-on/handlers/main.yml
---
- name: restart sshd
  service:
    name: sshd
    state: restarted
    enabled: yes
EOF