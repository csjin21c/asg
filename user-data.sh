#!/bin/bash

# 로그 기록 (문제 발생 시 /var/log/user-data.log 에서 확인 가능)
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# 1. SSM 에이전트 설치
# Ubuntu Snap 패키지 매니저를 사용하여 설치 및 활성화
snap install amazon-ssm-agent --classic
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# 2. 패키지 업데이트 및 필수 도구 설치
apt-get update -y
apt-get install -y curl unzip net-tools apt-transport-https ca-certificates gnupg lsb-release

# 3. Docker 설치 (공식 저장소 등록 방식)
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker 권한 설정 및 실행
systemctl enable --now docker
usermod -aG docker ubuntu

# 4. AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws/

# 5. 기존 애플리케이션 파일 제거 (디렉토리가 없을 경우 대비해 -p 추가)
mkdir -p /home/ubuntu/app
rm -rf /home/ubuntu/app/*

echo "User Data Script Completed!"
