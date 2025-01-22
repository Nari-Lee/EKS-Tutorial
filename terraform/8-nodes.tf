# EKS 워커 노드를 위한 IAM 역할 생성
resource "aws_iam_role" "nodes" {
  # 역할 이름 설정
  name = "${local.env}-${local.eks_name}-eks-nodes"

  # EC2 서비스가 이 역할을 사용할 수 있도록 하는 신뢰 정책
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
POLICY
}

# 워커 노드에 필요한 기본 정책 연결
# EKS 워커 노드 정책 (Pod Identity 기능 포함)
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# AWS CNI 플러그인을 위한 정책
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# ECR 읽기 전용 접근 정책
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# EKS 노드 그룹 생성
resource "aws_eks_node_group" "general" {
  # 노드 그룹이 속할 EKS 클러스터 이름
  cluster_name    = aws_eks_cluster.eks.name
  # 쿠버네티스 버전
  version         = local.eks_version
  # 노드 그룹 이름
  node_group_name = "general"
  # 노드가 사용할 IAM 역할
  node_role_arn   = aws_iam_role.nodes.arn

  # 노드가 생성될 서브넷 지정 (프라이빗 서브넷만 사용)
  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  # 인스턴스 구매 옵션 (온디맨드)
  capacity_type  = "ON_DEMAND"
  # 노드에 사용할 인스턴스 타입
  instance_types = ["t3.large"]

  # 노드 그룹 크기 설정
  scaling_config {
    desired_size = 1 # 원하는 노드 수
    max_size     = 10 # 최대 노드 수
    min_size     = 0 # 최소 노드 수
  }

  # 노드 업데이트 설정
  update_config {
    # 업데이트 시 최대 1개 노드까지 사용 불가 허용
    max_unavailable = 1
  }

  # 노드에 적용할 쿠버네티스 레이블
  labels = {
    role = "general"
  }

  # 필요한 정책이 모두 연결된 후에 노드 그룹 생성
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  # Terraform 외부에서 발생하는 노드 수 변경을 무시
  # 자동 스케일링으로 인한 변경 사항을 계획에 반영하지 않음
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
