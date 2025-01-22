# locals 블록: 테라폼 코드에서 재사용할 공통 변수들을 정의
locals {
  # 환경 구분 (예: staging, production 등)
  env         = "staging"

  # AWS 리전 지정
  region      = "us-east-2"

  # 가용영역(AZ) 지정 - 고가용성을 위해 2개의 AZ 사용
  zone1       = "us-east-2a"
  zone2       = "us-east-2b"

  # EKS 클러스터 이름
  eks_name    = "demo"

  # EKS 클러스터 버전 지정 (Kubernates 버전)
  eks_version = "1.30"
}
