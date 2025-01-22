# cert-manager Helm 차트를 설치하기 위한 리소스 정의
resource "helm_release" "cert_manager" {
  # 릴리스 이름 설정
  name = "cert-manager"

  # cert-manager 공식 Helm 차트 레포지토리 URL
  repository       = "https://charts.jetstack.io"

  # 설치할 차트 이름
  chart            = "cert-manager"

  # cert-manager가 설치될 네임스페이스
  namespace        = "cert-manager"

  # 네임스페이스가 없을 경우 자동으로 생성
  create_namespace = true

  # 설치할 cert-manager의 버전
  version          = "v1.15.0"

  # Helm 차트 값 설정
  set {
    # CRD(Custom Resource Definitions) 자동 설치 활성화
    name  = "installCRDs"
    value = "true"
  }

  # external-nginx Helm 차트가 먼저 설치된 후에 실행되도록 의존성 설정
  depends_on = [helm_release.external_nginx]
}
