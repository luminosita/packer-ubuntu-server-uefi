# Copyright 2024 Shantanoo 'Shan' Desai <sdes.softdev@gmail.com>

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#  limitations under the License.

NOBLE_ANSIBLE_VARS_FILE:=./images/ubuntu-noble-ansible.hcl
NOBLE_K3S_SERVER_VARS_FILE:=./images/ubuntu-noble-k3s-server.hcl
NOBLE_K3S_AGENT_VARS_FILE:=./images/ubuntu-noble-k3s-agent.hcl
NOBLE_K3S_ISTIO_VARS_FILE:=./images/ubuntu-noble-k3s-istio.hcl

HCL_FOLDER:=./hcl/

include common.mk

init-hcl:
	$(info PACKER: Init Packer plugins)
	packer init ${HCL_FOLDER}

hcl-noble-ansible-amd: validate-amd  validate-cloudinit
	$(info PACKER: Build Ansible template image (QEMU, AMD64))
	packer build -var arch="amd" -var-file=${NOBLE_ANSIBLE_VARS_FILE} -only=base.qemu.base ${HCL_FOLDER}

hcl-noble-ansible-arm: validate-arm
	$(info PACKER: Build Ansible template image (QEMU, ARM64))
	packer build -var arch="arm" -var-file=${NOBLE_ANSIBLE_VARS_FILE} -only=base.qemu.base ${HCL_FOLDER}

hcl-noble-k3s-server-amd: validate-amd  validate-cloudinit
	$(info PACKER: Remote configure K3S Server (QEMU, AMD64))
	packer build -var arch="amd" -var-file=${NOBLE_K3S_SERVER_VARS_FILE} -only=ansible-remote.null.ssh ${HCL_FOLDER}

hcl-noble-k3s-server-arm: validate-arm
	$(info PACKER: Remote configure K3S Server (QEMU, ARM64))
	packer build -var arch="arm" -var-file=${NOBLE_K3S_SERVER_VARS_FILE} -only=ansible-remote.null.ssh ${HCL_FOLDER}

hcl-noble-k3s-agent-amd: validate-amd  validate-cloudinit
	$(info PACKER: Remote configure K3S Agent (QEMU, AMD64))
	packer build -var arch="amd" -var-file=${NOBLE_K3S_AGENT_VARS_FILE} -only=ansible-remote.null.ssh ${HCL_FOLDER}

hcl-noble-k3s-agent-arm: validate-arm
	$(info PACKER: Remote configure K3S Agent (QEMU, ARM64))
	packer build -var arch="arm" -var-file=${NOBLE_K3S_AGENT_VARS_FILE} -only=ansible-remote.null.ssh ${HCL_FOLDER}

hcl-noble-k3s-istio-amd: validate-amd
	$(info PACKER: Remote configure Istio Mesh (QEMU, AMD64))
	packer build -var arch="amd" -var-file=${NOBLE_K3S_ISTIO_VARS_FILE} -only=ansible-remote.null.ssh ${HCL_FOLDER}

hcl-noble-k3s-istio-arm: validate-arm
	$(info PACKER: Remote configure Istio Mesh (QEMU, ARM64))
	packer build -var arch="arm" -var-file=${NOBLE_K3S_ISTIO_VARS_FILE} -only=ansible-remote.null.ssh ${HCL_FOLDER}

validate-amd: init-hcl
	$(info PACKER: Validating Template with Ubuntu 24.04 (Noble Numbat) Packer Variables)
	packer validate -var arch="amd" ${HCL_FOLDER}

validate-arm: init-hcl
	$(info PACKER: Validating Template with Ubuntu 24.04 (Noble Numbat) Packer Variables)
	packer validate -var arch="arm" ${HCL_FOLDER}

validate-cloudinit: init-hcl
	$(info CLOUD-INIT: Validating Ubuntu 24.04 (Noble Numbat) Cloud-Config File)
	cloud-init schema -c cloud/cloud.cfg

#Make seed.img used by qemu to initialize cloud images and download proper QEMU EFI bios
prepare-arm: seed-arm qemu-efi download-noble-cloud-arm generate-k3s-token prepare-python-arm

prepare-amd: seed-amd qemu-efi download-noble-cloud-amd generate-k3s-token prepare-python-amd

seed-arm:
	$(info DOCKER: Create Seed image for Cloud-init)
	docker run -it -v $(shell pwd)/cloud:/tmp/host --rm luminosita/cloud-init:latest cloud-localds /tmp/host/seed.img /tmp/host/cloud.cfg

seed-amd:
	$(info CLOUD-LOCALDS: Create Seed image for Cloud-init)
	cloud-localds cloud/seed.img cloud/cloud.cfg

qemu-efi:
	$(info CURL: Download QEMU EFI bios)
	curl -L https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/EFI.fd -o EFI.fd

download-noble-cloud-amd:
	$(info CURL: Ubuntu 24.04 (Noble Numbat) and setup local VM images repository)
	mkdir -p ${REPO_ROOT}/ubuntu-noble/24.04
	curl -L https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img -o ${REPO_ROOT}/ubuntu-noble/24.04/ubuntu-noble-24.04.img

download-noble-cloud-arm:
	$(info CURL: Ubuntu 24.04 (Noble Numbat) and setup local VM images repository)
	mkdir -p ${REPO_ROOT}/ubuntu-noble/24.04
	curl -L https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img -o ${REPO_ROOT}/ubuntu-noble/24.04/ubuntu-noble-24.04.img

generate-k3s-token:
# 	$(info K3S: Generate K3S TOKEN)
# 	$(info OLD K3S TOKEN: ${K3S_TOKEN_VAR})

# 	NEW_TOKEN=$(shell docker run --entrypoint "" -it --rm rancher/k3s:latest /bin/k3s token generate); \
# 	printf '%s' "$$NEW_TOKEN" >${K3S_TOKEN_FILE}

# 	$(info NEW K3S TOKEN: ${NEW_TOKEN})

prepare-python-amd:
	$(info SHELL: Prepare Python Virtual Environment for Ansible)
	
	sudo apt -y update && \
	sudo apt -y upgrade && \
	sudo apt install -y python3-venv

	mkdir python-venv && \
	cd python-venv && \
	python3 -m venv ansible

	./python-venv/ansible/bin/python3 -m pip install --upgrade pip && \
	./python-venv/ansible/bin/python3 -m pip install ansible

prepare-python-arm:
	$(info SHELL: Prepare Python Virtual Environment for Ansible)

	mkdir python-venv && \
	cd python-venv && \
	python3 -m venv ansible

	./python-venv/ansible/bin/python3 -m pip install --upgrade pip && \
	./python-venv/ansible/bin/python3 -m pip install ansible
