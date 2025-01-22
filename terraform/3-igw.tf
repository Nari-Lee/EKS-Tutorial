# 인터넷 게이트웨이(IGW) 생성
# IGW는 VPC와 인터넷 간의 통신을 가능하게 하는 게이트웨이
resource "aws_internet_gateway" "igw" {
  # 생성한 IGW를 어떤 VPC에 연결할지 지정
  # aws_vpc.main의 ID를 잠조하여 연결
  vpc_id = aws_vpc.main.id

  # 리소스를 식별하기 위한 태그 설정
  # local.env 값을 사용하여 환경(staging, production 등)을 구분
  tags = {
    Name = "${local.env}-igw"
  }
}
