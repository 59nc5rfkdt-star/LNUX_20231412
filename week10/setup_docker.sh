#!/bin/bash

# 1. 실습 디렉토리 이동
PROJECT_DIR="$HOME/linux/week10/wordpress"
cd $PROJECT_DIR || { echo "디렉토리를 찾을 수 없습니다."; exit 1; }

# 2. 필수 설정 파일 및 환경 변수 체크
echo "=== 설정 파일 및 환경 변수 체크 ==="
if [ ! -f ".env" ] || [ ! -f "./nginx/default.conf" ]; then
    echo "[오류] .env 또는 nginx/default.conf 파일이 누락되었습니다."
    exit 1
fi

# 3. 9주차 LVM 스토리지 마운트 상태 확인
echo "=== MySQL 전용 LVM 스토리지 확인 ==="
if ! df -hT | grep -q "/mnt/mysql_data"; then
    echo "[경고] /mnt/mysql_data 마운트가 확인되지 않습니다."
    echo "9주차 setup_disks.sh를 먼저 실행해야 합니다."
    exit 1
fi

# 4. 기존 서비스 정리
echo "=== 기존 서비스 정리 ==="
docker compose \
  -f compose.db.yaml \
  -f compose.wordpress.yaml \
  -f compose.nginx.yaml \
  -f compose.portainer.yaml \
  -f compose.netdata.yaml down

# 5. 분리된 YAML 파일 병합 실행
echo "=== 3-Tier 아키텍처 및 모니터링 병합 실행 시작 ==="
docker compose \
  -f compose.db.yaml \
  -f compose.wordpress.yaml \
  -f compose.nginx.yaml \
  -f compose.portainer.yaml \
  -f compose.netdata.yaml up -d

# 6. 최종 상태 확인
echo "=== 서비스 전체 상태(PS) 확인 ==="
docker compose \
  -f compose.db.yaml \
  -f compose.wordpress.yaml \
  -f compose.nginx.yaml \
  -f compose.portainer.yaml \
  -f compose.netdata.yaml ps

echo "=== 모든 준비 완료 ==="
echo "웹 서버: http://localhost:8080"
echo "포테이너: https://localhost:9443"
echo "넷데이터: http://localhost:19999"
