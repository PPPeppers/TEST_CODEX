# 고닷퀘스트 / GodotQuest

외부 이미지와 사운드 없이 기본 도형으로 만든 3800px 2D 플랫포머입니다.
Godot 4.7.2 / GDScript / Compatibility 렌더러, 1280×720 canvas_items / keep 설정을 사용합니다.

## 조작
- A/D 또는 좌우 방향키: 이동
- Shift/Z 또는 B 터치 버튼: 달리기 (지속 이동 1.2초 후 자동 달리기도 가능)
- Space/W/위 방향키 또는 A 터치 버튼: 점프
- 점프를 짧게 누르면 낮게, 달리면서 뛰면 더 높고 멀리 점프합니다.
- 적을 위에서 밟으면 제거되고 튕겨 오릅니다. 측면 접촉과 낙사는 스테이지를 재시작합니다.
- 노란 깃발 도달 시 조작을 멈추고 3초 후 타이틀로 돌아갑니다.

## 파일
- scenes/TitleScene.tscn, scripts/TitleScene.gd: 타이틀 및 START
- scenes/Stage1.tscn, scripts/Stage1.gd: 지형, 적, 골, HUD, 클리어
- scenes/Player.tscn, scripts/Player.gd: 이동, 가속, 가변 점프, 카메라
- scenes/Enemy.tscn, scripts/Enemy.gd: 순찰, 밟기, 측면 접촉
- scripts/TouchControls.gd: CanvasLayer 안의 멀티터치 TouchScreenButton 4개
- export_presets.cfg: single-threaded Web
- .github/workflows/web.yml: main/PR Web 빌드, main 빌드 성공 시 GitHub Pages 배포

반복 지형과 UI 노드는 스크립트에서 생성합니다.
한글 폰트를 배포하지 않으므로 영문을 병기합니다. 필요하면 TitleScene.gd 주석에 따라 한글 폰트를 추가하세요.

## 실행 및 Web 빌드
엔진과 동일한 버전의 공식 Export Templates를 설치하세요.

```sh
godot --headless --path . --editor --import --quit
godot --path . --editor
mkdir -p build/web
godot --headless --path . --export-release Web build/web/index.html
python3 -m http.server 8000 --directory build/web --bind 0.0.0.0
```

HTTP 서버 8000 포트를 포워딩합니다. file:// 직접 열기는 지원하지 않습니다.
variant/thread_support=false이므로 스레드용 SharedArrayBuffer/COOP/COEP에 의존하지 않습니다.
WebGL 2 지원 브라우저가 필요합니다.

## GitHub Pages 배포
저장소 Settings → Pages → Build and deployment → Source를 GitHub Actions로 설정하세요.
main 푸시 또는 main에서 수동 실행하면 Web export가 build/web/index.html과 관련 파일을 생성하고,
전체 build/web 폴더를 Pages 아티팩트로 업로드한 뒤 deploy-pages로 배포합니다.
PR에서는 빌드 검증만 수행합니다. 배포 주소는 Actions의 github-pages 환경에 표시됩니다.
