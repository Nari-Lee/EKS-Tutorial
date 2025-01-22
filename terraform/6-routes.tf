# 프라이빗 서브넷을 위한 라우팅 테이블
resource "aws_route_table" "private" {
  # 라우팅 테이블이 속할 VPC 지정
  vpc_id = aws_vpc.main.id

  # 라우팅 규칙 설정
  route {
    # 모든 외부 트래픽(0.0.0.0/0)을
    cidr_block     = "0.0.0.0/0"
    # NAT 게이트웨이로 보냄
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  # 태그 설정
  tags = {
    Name = "${local.env}-private"
  }
}

# 퍼블릭 서브넷을 위한 라우팅 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    # 모든 외부 트래픽(0.0.0.0/0)을
    cidr_block = "0.0.0.0/0"
    # 인터넷 게이트웨이로 보냄
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.env}-public"
  }
}

# 프라이빗 서브넷과 라우팅 테이블 연결 - 가용영역 1
resource "aws_route_table_association" "private_zone1" {
  # 연결할 서브넷 지정
  subnet_id      = aws_subnet.private_zone1.id
  # 연결할 라우팅 테이블 지정
  route_table_id = aws_route_table.private.id
}

# 프라이빗 서브넷과 라우팅 테이블 연결 - 가용영역 2
resource "aws_route_table_association" "private_zone2" {
  subnet_id      = aws_subnet.private_zone2.id
  route_table_id = aws_route_table.private.id
}

# 퍼블릿 서브넷과 라우팅 테이블 연결 - 가용영역 1
resource "aws_route_table_association" "public_zone1" {
  subnet_id      = aws_subnet.public_zone1.id
  route_table_id = aws_route_table.public.id
}

# 퍼블릿 서브넷과 라우팅 테이블 연결 - 가용영역 2
resource "aws_route_table_association" "public_zone2" {
  subnet_id      = aws_subnet.public_zone2.id
  route_table_id = aws_route_table.public.id
}
