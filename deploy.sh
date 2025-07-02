#!/bin/bash

echo "=== AjouEvent 쿠버네티스 배포 시작 ==="

# 네임스페이스 생성
echo "1. 네임스페이스 생성 중..."
kubectl apply -f kubernetes/namespace.yaml

# MySQL 배포
echo "2. MySQL StatefulSet 배포 중..."
kubectl apply -f kubernetes/mysql/mysql-statefulset.yaml

# Redis 배포
echo "3. Redis 배포 중..."
kubectl apply -f kubernetes/redis/redis-deployment.yaml

# MySQL이 준비될 때까지 대기
echo "4. MySQL 준비 대기 중..."
kubectl wait --for=condition=ready pod -l app=mysql -n ajouevent --timeout=300s

# Redis가 준비될 때까지 대기
echo "5. Redis 준비 대기 중..."
kubectl wait --for=condition=ready pod -l app=redis -n ajouevent --timeout=300s

# Backend 배포
echo "6. 백엔드 서비스 배포 중..."
kubectl apply -f kubernetes/backend/backend-deployment.yaml

# Crawling 배포
echo "7. 크롤링 서비스 배포 중..."
kubectl apply -f kubernetes/crawling/crawling-deployment.yaml

# Ingress 배포
echo "8. Ingress 설정 중..."
kubectl apply -f kubernetes/ingress/ingress.yaml

echo "=== 배포 완료! ==="
echo "다음 명령어로 상태를 확인하세요:"
echo "kubectl get pods -n ajouevent"
echo "kubectl get services -n ajouevent"
echo "kubectl get ingress -n ajouevent"
