# AjouEvent 모니터링 시스템

## 개요
AjouEvent 서비스를 쿠버네티스 클러스터에 배포하고 모니터링하기 위한 리포지토리입니다.

## 서비스 구성
1. **백엔드 (Backend)**: Spring Boot 애플리케이션
2. **크롤링 서버 (Crawling)**: Go 애플리케이션
3. **MySQL 데이터베이스**: StatefulSet + PVC
4. **Redis (Valkey)**: Deployment

## 디렉토리 구조
```
.
├── backend/
│   └── Dockerfile
├── crawling/
│   └── Dockerfile
└── kubernetes/
    ├── backend/
    ├── crawling/
    ├── mysql/
    └── redis/
```

## Docker 이미지 빌드
### 백엔드
```bash
docker build -t ajouevent_be:latest backend/
```

### 크롤링 서버
```bash
docker build -t ajouevent_crawling:latest crawling/
```

## 쿠버네티스 배포
각 서비스별 매니페스트 파일을 사용하여 쿠버네티스 클러스터에 배포합니다. 