# EKS 클러스터 데이터 소스 정으
# 생성된 EKS 클러스터의 정보를 가져오기 위한 데이터 소스
data "aws_eks_cluster" "eks" {
  # 생성된 EKS 클러스터의 이름 참조
  name = aws_eks_cluster.eks.name
}

# ELS 클러스터 인증 데이터 소스 정의
# 클러스터에 접근하기 위한 인증 토큰을 가져오기 위한 데이터 소스
data "aws_eks_cluster_auth" "eks" {
  # 인증이 필요한 EKS 클러스터의 이름 참조
  name = aws_eks_cluster.eks.name
}

# Helm Provider 구성
# Kubernetes 클러스터에 Helm 차트를 베포하기 위한 provider 설정
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
