# Cluster Autoscaler를 위한 IAM 역할 생성
resource "aws_iam_role" "cluster_autoscaler" {
  # EKS 클러스터 이름을 포함한 역할 이름 설정
  name = "${aws_eks_cluster.eks.name}-cluster-autoscaler"

  # Pod Identity를 사용하여 EKS 파드가 이 역할을 사용할 수 있도록 신뢰 정책 설정
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

# Cluster Autoscaler를 위한 IAM 정책 생성
resource "aws_iam_policy" "cluster_autoscaler" {
  name = "${aws_eks_cluster.eks.name}-cluster-autoscaler"

  # Autoscaling 관련 권한을 정의하는 정책 문서
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      },
    ]
  })
}

# IAM 역할과 정책 연결
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler.name
}

# Pod Identity와 서비스 계정 연결 설정
resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"           # Autoscaler가 실행될 네임스페이스
  service_account = "cluster-autoscaler"    # 사용할 서비스 계정 이름
  role_arn        = aws_iam_role.cluster_autoscaler.arn  # 연결할 IAM 역할
}

# Cluster Autoscaler Helm 차트 배포
resource "helm_release" "cluster_autoscaler" {
  name = "autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"  # Helm 차트 저장소
  chart      = "cluster-autoscaler"  # 설치할 차트 이름
  namespace  = "kube-system"         # 설치할 네임스페이스
  version    = "9.37.0"             # 차트 버전

  # 서비스 계정 이름 설정
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  # 클러스터 이름 자동 검색 설정
  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks.name
  }

  # AWS 리전 설정 (반드시 본인의 리전으로 수정 필요)
  set {
    name  = "awsRegion"
    value = "us-east-2"
  }

  # Metrics Server가 설치된 후에 배포되도록 의존성 설정
  depends_on = [helm_release.metrics_server]
}
