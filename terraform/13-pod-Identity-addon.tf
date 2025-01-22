# EKS Pod Identity Agent 애드온 설정
resource "aws_eks_addon" "pod_identity" {
  # 애드온을 설치할 EKS 클러스터 이름
  cluster_name  = aws_eks_cluster.eks.name

  # 설치할 애드온의 이름
  # eks-pod-identity-agent는 파드 수준의 IAM 권한 관리를 위한 애드온
  addon_name    = "eks-pod-identity-agent"

  # 애드온의 버전 지정
  # v1.2.0-eksbuild.1은 EKS에서 빌드된 1.2.0 버전을 의미
  addon_version = "v1.2.0-eksbuild.1"
}
