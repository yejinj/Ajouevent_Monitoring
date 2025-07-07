#!/bin/bash

# AjouEvent 배포 스크립트
set -e

echo "🚀 AjouEvent 배포를 시작합니다..."

# 현재 디렉터리 확인
if [ ! -f "kustomization.yaml" ]; then
    echo "❌ kustomization.yaml 파일이 없습니다. 프로젝트 루트 디렉터리에서 실행하세요."
    exit 1
fi

# 환경 변수 로드
if [ -f ".env" ]; then
    echo "📄 환경 변수를 로드합니다..."
    source .env
fi

# Docker 이미지 빌드 옵션
BUILD_IMAGES=${BUILD_IMAGES:-"false"}

if [ "$BUILD_IMAGES" = "true" ]; then
    echo "🔨 Docker 이미지를 빌드합니다..."
    
    # Backend 이미지 빌드
    echo "  📦 Backend 이미지 빌드 중..."
    docker build -t ajouevent/backend:latest ./backend-src
    
    # Crawler 이미지 빌드  
    echo "  📦 Crawler 이미지 빌드 중..."
    docker build -t ajouevent/crawler:latest -f ./crawler-src/docker/Dockerfile ./crawler-src
    
    echo "✅ 이미지 빌드 완료"
fi

# Kubernetes 클러스터 연결 확인
echo "🔍 Kubernetes 클러스터 연결을 확인합니다..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes 클러스터에 연결할 수 없습니다."
    exit 1
fi

# Namespace 생성 (없는 경우)
echo "🏗️  Namespace 생성 중..."
kubectl create namespace ajouevent --dry-run=client -o yaml | kubectl apply -f -

# Secret 생성 (환경 변수 사용)
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    echo "🔒 MySQL Secret 업데이트 중..."
    kubectl create secret generic ajouevent-secret \
        --from-literal=mysql-root-password="$MYSQL_ROOT_PASSWORD" \
        --from-literal=mysql-password="$MYSQL_PASSWORD" \
        --from-literal=jwt-secret="$JWT_SECRET" \
        --namespace=ajouevent \
        --dry-run=client -o yaml | kubectl apply -f -
fi

# 매니페스트 배포
echo "📦 Kubernetes 매니페스트를 배포합니다..."
kubectl apply -k .

# 배포 상태 확인
echo "⏳ 배포 상태를 확인합니다..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n ajouevent || true
kubectl wait --for=condition=available --timeout=300s deployment/crawler -n ajouevent || true
kubectl wait --for=condition=available --timeout=300s deployment/redis -n ajouevent || true

# 서비스 상태 출력
echo "📊 배포 상태:"
kubectl get pods -n ajouevent -o wide
echo ""
kubectl get services -n ajouevent

echo "✅ 배포가 완료되었습니다!"
echo ""
echo "🔍 로그 확인:"
echo "  kubectl logs -f deployment/backend -n ajouevent"
echo "  kubectl logs -f deployment/crawler -n ajouevent"
echo ""
echo "🌐 포트 포워딩:"
echo "  kubectl port-forward service/backend-service 8080:8080 -n ajouevent"
echo "  kubectl port-forward service/crawler-service 1323:1323 -n ajouevent" 