# 개발자를 위한 IAM 사용자 생성
resource "aws_iam_user" "developer" {
  name = "developer"
}

# 개발자를 위한 EKS 접근 정책 생성
resource "aws_iam_policy" "developer_eks" {
  name = "AmazonEKSDeveloperPolicy"

  # 정책 내용 정의
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                # EKS 클러스터 정보 조회 권한
                "eks:DescribeCluster",
                # EKS 클러스터 목록 조회 권한
                "eks:ListClusters"
            ],
            # 모든 EKS 클러스터에 대해 적용
            "Resource": "*"
        }
    ]
}
POLICY
}

# 개발자 사용자에게 EKS 정책 연결
resource "aws_iam_user_policy_attachment" "developer_eks" {
  # 정책을 연결할 사용자
  user       = aws_iam_user.developer.name
  # 연결할 정책의 ARN
  policy_arn = aws_iam_policy.developer_eks.arn
}

# EKS 클러스터에 대한 개발자 접근 설정
resource "aws_eks_access_entry" "developer" {
  # 접근 설정을 할 EKS 클러스터 이름
  cluster_name      = aws_eks_cluster.eks.name
  # 접근 권한을 부여할 IAM 사용자
  principal_arn     = aws_iam_user.developer.arn
  # 쿠버네티스 내에서 부여할 그룹
  # my-viewer 그룹은 일반적으로 읽기 전용 권한을 가진 그룹으로 설정됨
  kubernetes_groups = ["my-viewer"]
}
