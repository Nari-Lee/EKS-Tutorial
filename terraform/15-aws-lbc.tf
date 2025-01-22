# AWS Load Balancer Controller를 위한 IAM 신뢰 정책 문서 정의
data "aws_iam_policy_document" "aws_lbc" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]    # EKS 파드가 이 역할을 사용할 수 있도록 설정
    }
    actions = [
      "sts:AssumeRole",     # 역할 수임 권한
      "sts:TagSession"      # 세션 태깅 권한
    ]
  }
}

# Load Balancer Controller를 위한 IAM 역할 생성
resource "aws_iam_role" "aws_lbc" {
  name               = "${aws_eks_cluster.eks.name}-aws-lbc"  # EKS 클러스터 이름을 포함한 역할 이름
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json  # 위에서 정의한 신뢰 정책 적용
}

# Load Balancer Controller에 필요한 IAM 정책 생성
resource "aws_iam_policy" "aws_lbc" {
  policy = file("./iam/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

# IAM 역할과 정책 연결
resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn  # 생성한 정책의 ARN
  role       = aws_iam_role.aws_lbc.name   # 연결할 IAM 역할
}

# Pod Identity와 서비스 계정 연결 설정
resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"                    # Controller가 실행될 네임스페이스
  service_account = "aws-load-balancer-controller"   # 사용할 서비스 계정 이름
  role_arn        = aws_iam_role.aws_lbc.arn        # 연결할 IAM 역할
}

# AWS Load Balancer Controller Helm 차트 배포
resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"    # AWS EKS Helm 차트 저장소
  chart      = "aws-load-balancer-controller"        # 설치할 차트 이름
  namespace  = "kube-system"                         # 설치할 네임스페이스
  version    = "1.8.1"                              # 차트 버전

  # EKS 클러스터 이름 설정
  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.name
  }

  # 서비스 계정 이름 설정
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  # VPC ID 설정
  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }

  # Cluster Autoscaler가 설치된 후에 배포되도록 의존성 설정
  depends_on = [helm_release.cluster_autoscaler]
}
