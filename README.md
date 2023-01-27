# terraform-ceph

## Introduction

This is a Terraform-Project which prepares an infrastructure for a ceph cluster in an OpenStack-Cloud.
I mainly use it for rapidly setting up a cluster for research and experimenting reasons.
This is not meant for production usage!

The following pieces are set up by terraform:

- Network infrastructure including a frontend and backend network for ceph. Also creates a router for floatingIP-access.
- A variable defined amount of monitor and osd nodes.
- A variable defined amount of osd disks.
- A gateway instance for accessing nodes via `sshuttle`.

## Usage

Create [Application Credentials](https://cloud.denbi.de/wiki/Compute_Center/Bielefeld/#application-credentials-use-openstack-api) and place them in `~/.config/openstack/`

Check the contents in `tf/variable.tf` and overwrite variables for your setup.
You have to overwrite your own variables for:

- Image ID (`openstack image list`)
- Keypair-Name (`openstack keypair list`)
- Flavor ID (`openstack flavor list`)
- External network (`openstack network list --external`)

Use a clean project in OpenStack and make sure that your quotas are appropriate.

Afterwards apply the infrastructure:

```bash
cd tf/
terraform init
terraform plan
terraform apply
```

## Follow-up deployment

Using Ansible, you can deploy ceph with the official [ceph-ansible](https://docs.ceph.com/projects/ceph-ansible/en/latest/index.html) playbooks:

```bash
python3 -m venv myVenv
source myVenv/bin/activate
git clone https://github.com/ceph/ceph-ansible.git
pip install -r ceph-ansible/requirements.txt
pip install sshuttle
```

Per default, the gateway-instance gets a floatingIP attached which you need to look up.
With this informations you can create a tunnel to your ceph infrastructure:

```
sshuttle -e "ssh -i <your_private_key>" -r ubuntu@<floating_ip_to_gateway> 192.168.199.0/24
```

`ceph-ansible` requires some variables. When using the defaults provided in the repository, you may use the examples provided in `group_vars/`:

```bash
cp group_vars/*.yml ceph-ansible/group_vars/
```

Also when using the default setup, you can use this hosts file.
Save this in `ceph-ansible/hosts`:

```ini
[monitoring]
192.168.199.50
192.168.199.51
192.168.199.52

[mons]
192.168.199.50
192.168.199.51
192.168.199.52

[mdss]
192.168.199.50
192.168.199.51
192.168.199.52

[mgrs]
192.168.199.50
192.168.199.51
192.168.199.52

[osds]
192.168.199.100
192.168.199.101
192.168.199.102
192.168.199.103
192.168.199.104
192.168.199.105
```

Afterwards you can run `ansible-playbook`:

```bash
cd ceph-ansible/
ansible-playbook  -u ubuntu --private-key ~/.ssh/os-bibi.key -i hosts site.yml
```


## Misc
Alex Walender

de.NBI Cloud Bielefeld