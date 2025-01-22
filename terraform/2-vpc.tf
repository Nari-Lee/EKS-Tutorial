# VPC(Virtual Private Cloud) 리소스 생성
resource "aws_vpc" "main" {
  # VPC의 IP 주소 범위 설정
  # 10.0.0.0/16은 10.0.0.0 ~ 10.0.255.255 범위의 IP주소를 사용 가능
  # 총 65,536개의 IP 주소 사용 가능
  cidr_block = "10.0.0.0/16"

  # AWS DNS 서버를 통한 DNS 확인 활성화
  # VPC 내의 인스턴스가 AWS의 DNS 서버를 사용할 수 있게 됨
  enable_dns_support   = true

  # VPC 내 인스턴스에 퍼블릭 DNS 호스트네임 자동 할당 활성화
  # 퍼블릭 IP가 있는 인스턴스에 자동으로 DNS 이름이 할당됨
  enable_dns_hostnames = true

  # 태그 설정
  # local.env 값을 사용하여 환경(staging, production 등)을 구분
  tags = {
    Name = "${local.env}-main"
  }
}
