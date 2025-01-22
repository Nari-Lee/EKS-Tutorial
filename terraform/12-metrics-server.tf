# Metrics Server Helm 차트 배포를 위한 리소스 정의
resource "helm_release" "metrics_server" {
  # Helm release의 이름 지정
  name = "metrics-server"

  # Metrics Server Helm 차트의 저장소 URL
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  # 설치할 Helm 차트 이름
  chart      = "metrics-server"
  # 차트가 설치될 Kubernetes 네임스페이스
  namespace  = "kube-system"
  # 설치할 Metrics Server의 버전
  version    = "3.12.1"

  # Helm 차트의 사용자 정의 설정값이 포함된 YAML 파일 경로
  values = [file("${path.module}/values/metrics-server.yaml")]

  # EKS 노드 그룹이 생성된 후에 Metrics Server 설치 진행
  depends_on = [aws_eks_node_group.general]
}
