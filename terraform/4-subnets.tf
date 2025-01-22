# 프라이빗 서브넷 - 가용영역 1
resource "aws_subnet" "private_zone1" {
  # 서브넷이 속할 VPC 지정
  vpc_id            = aws_vpc.main.id
  # 서브넷의 IP 주소 범위
  cidr_block        = "10.0.0.0/19"
  # 서브넷이 위치할 가용영역 지정
  availability_zone = local.zone1

  # 태그 성정
  tags = {
    # 서브넷 이름
    "Name"                                                 = "${local.env}-private-${local.zone1}"
    # 내부용 로드밸런서가 사용할 서브넷임을 표시
    "kubernetes.io/role/internal-elb"                      = "1"
    # 이 서브넷이 특정 EKS 클러스터에 속함을 표시
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

# 프라이빗 서브넷 - 가용영역 2
resource "aws_subnet" "private_zone2" {
  vpc_id            = aws_vpc.main.id
  # 두번쨰 프라이빗 서브넷의 IP 주소 범위
  cidr_block        = "10.0.32.0/19"
  availability_zone = local.zone2

  tags = {
    "Name"                                                 = "${local.env}-private-${local.zone2}"
    "kubernetes.io/role/internal-elb"                      = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

# 퍼블릭 서브넷 - 가용영역 1
resource "aws_subnet" "public_zone1" {
  vpc_id                  = aws_vpc.main.id
  # 첫번쨰 퍼블릭 서브넷의 IP주소 범위
  cidr_block              = "10.0.64.0/19"
  availability_zone       = local.zone1
  # 이 서브넷에서 시장되는 인스턴스에 자동으로 퍼블릭 IP 할당
  map_public_ip_on_launch = true

  tags = {
    "Name"                                                 = "${local.env}-public-${local.zone1}"
    # 외부용 로드밸런서가 사용할 서브넷임을 표시
    "kubernetes.io/role/elb"                               = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}

# 퍼블릭 서브넷 - 가용영역 2
resource "aws_subnet" "public_zone2" {
  vpc_id                  = aws_vpc.main.id
  # 두번째 퍼블릭 서브넷의 IP 주소 범위
  cidr_block              = "10.0.96.0/19"
  availability_zone       = local.zone2
  map_public_ip_on_launch = true

  tags = {
    "Name"                                                 = "${local.env}-public-${local.zone2}"
    "kubernetes.io/role/elb"                               = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
  }
}
