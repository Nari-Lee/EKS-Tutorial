# 현재 AWS 계정 ID를 가져옵니다.
data "aws_caller_identity" "current" {}

# EKS 관리자를 위한 IAM 역할 생성
resource "aws_iam_role" "eks_admin" {
  # 역할 이름은 환경변수와 EKS 이름을 조합하여 생성
  name = "${local.env}-${local.eks_name}-eks-admin"

  # 이 역할을 누가 맡을 수 있을지 정의하는 신뢰 정책
  # 현재 AWS 계정의 root 사용자가 이 역활을 수임 할 수 있음
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
    }
  ]
}
POLICY
}

# EKS 관리자를 위한 IAM 정책 생성
resource "aws_iam_policy" "eks_admin" {
  name = "AmazonEKSAdminPolicy"

  # 정책 내용 정의
  # 1. EKS 관련 모든 작업 허용
  # 2. EKS 서비스에 IAM 역할을 전달할 수 있는 권한 부여
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        }
    ]
}
POLICY
}

# 생성한 정책을 EKS 관리자 역할에 연결
resource "aws_iam_role_policy_attachment" "eks_admin" {
  role       = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin.arn
}

# manager라는 이름의 IAM 사용자 생성
resource "aws_iam_user" "manager" {
  name = "manager"
}

# manager 가 eks_admin 역할을 수임할 수 있도록 하는 정책 생성
resource "aws_iam_policy" "eks_assume_admin" {
  name = "AmazonEKSAssumeAdminPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "${aws_iam_role.eks_admin.arn}"
        }
    ]
}
POLICY
}

# eks_assume_admin 정책을 manager 에게 연결
resource "aws_iam_user_policy_attachment" "manager" {
  user       = aws_iam_user.manager.name
  policy_arn = aws_iam_policy.eks_assume_admin.arn
}

# EKS 클러스터의 접근 권한 설정
# eks_admin 역할이 EKS 클러스터에서 'my-admin' 그룹의 권한을 가지도록 설정
resource "aws_eks_access_entry" "manager" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = aws_iam_role.eks_admin.arn
  kubernetes_groups = ["my-admin"]
}
