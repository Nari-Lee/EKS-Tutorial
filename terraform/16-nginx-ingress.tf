# NGINX Ingress Controller를 위한 Helm 차트 배포
resource "helm_release" "external_nginx" {
  # Helm Release 이름
  name = "external"

  # NGINX Ingress Controller의 공식 Helm 차트 저장소
  repository       = "https://kubernetes.github.io/ingress-nginx"

  # 설치할 Helm 차트 이름
  chart            = "ingress-nginx"

  # 설치할 네임스페이스 지정
  namespace        = "ingress"

  # 네임스페이스가 없는 경우 자동으로 생성
  create_namespace = true

  # 설치할 차트의 버전
  version          = "4.10.1"

  # 사용자 정의 설정값이 포함된 YAML 파일 경로
  values = [file("${path.module}/values/nginx-ingress.yaml")]

  # AWS Load Balancer Controller가 설치된 후에 배포되도록 의존성 설정
  depends_on = [helm_release.aws_lbc]
}
