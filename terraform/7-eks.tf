# EKS 클러스터를 위한 IAM 역할 생성
resource "aws_iam_role" "eks" {
  # 역할 이름 설정
  name = "${local.env}-${local.eks_name}-eks-cluster"

  # EKS 서비스가 이 역할을 사용할 수 있도록 하는 신뢰 정책
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# EKS 클러스터 정책을 IAM 역할에 연결
resource "aws_iam_role_policy_attachment" "eks" {
  # AWS에서 관리하는 EKS 클러스터 정책 사용
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

# EKS 클러스터 생성
resource "aws_eks_cluster" "eks" {
  # 클러스터 이름 설정
  name     = "${local.env}-${local.eks_name}"
  # 쿠버네티스 버전 설정
  version  = local.eks_version
  # 클러스터가 사용할 IAM 역할
  role_arn = aws_iam_role.eks.arn

  # VPC 설정
  vpc_config {
    # 프라이빗 엔드포인트 비활성화 (VPC 내부에서만 접근 불가)
    endpoint_private_access = false
    # 퍼블릿 엔드포인트 활성화 (인터넷에서 접근 가능)
    endpoint_public_access  = true

    # 클러스터가 사용할 서브넷 지정
    # 프라이빗 서브넷만 지정하여 워커 노드들이 프라이빗 서브넷에만 생성되도록 함
    subnet_ids = [
      aws_subnet.private_zone1.id,
      aws_subnet.private_zone2.id
    ]
  }

  # 접근 설정
  access_config {
    # API 서버 인증 모드 설정
    authentication_mode                         = "API"
    # 클러스터 생성자에게 자동으로 관리자 권한 부여
    bootstrap_cluster_creator_admin_permissions = true
  }

  # IAM 역할 정책이 먼저 연결되어 있어야 클러스터 생성 가능
  depends_on = [aws_iam_role_policy_attachment.eks]
}
