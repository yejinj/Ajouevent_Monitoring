#!/bin/bash

# AjouEvent 간소화 배포 스크립트
set -e

echo "🚀 AjouEvent 배포 시작..."

# Kubernetes 배포
echo "📦 Kubernetes 매니페스트 배포 중..."
kubectl apply -k .

# 배포 상태 확인
echo "📊 배포 상태 확인 중..."
kubectl get pods -n ajouevent

echo "✅ 배포 완료!"
echo ""
echo "🔍 상태 확인: kubectl get pods -n ajouevent"
echo "📋 로그 확인: kubectl logs -f deployment/backend -n ajouevent" 