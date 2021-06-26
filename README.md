# Metamong
![이미지](./screenshots/appearance.png)
> 따라하는 운동습관, Metamong

## 개발 목표
COVID-19 팬데믹의 장기화로 인한 비대면 생활이 일상화됨에 장소에 국한되지 않고 집에서 운동하는 ‘홈트족’ 들 또한 크게 늘어나고 있습니다. 그에 따라 홈 트레이닝 관련 시장의 규모 또한 급격히 커지고 있는 상황입니다. 이에 발맞춰 Human Pose Estimation을 통한 포즈 분석으로 사용자에게 피드백을 제공해 올바른 운동자세의 학습과 더불어 운동하는 재미를 줄 수 있는 어플리케이션의 개발을 목표로 합니다.

## 기능
| 검색 | 업로드 | 다운로드 | 포즈추출 |
|:---:|:---:|:---:|:---:|
|![검색](./screenshots/searching.gif)|![업로드](./screenshots/creating.gif)|![다운로드](./screenshots/download.gif)|![포즈추출](./screenshots/estimation.gif)|
1. 검색 : 키워드를 입력해 서버에 업로드 되어있는 제작된 컨텐츠를 검색할 수 있습니다.
2. 업로드 : 운동 영상을 촬영해 그 영상과 분석된 포즈, 메타데이터를 서버에 업로드 할 수 있습니다.
3. 다운로드 : 제작된 운동 컨텐츠를 서버로부터 내려받을 수 있습니다.
4. 포즈추출 : 사용자가 컨텐츠의 영상을 따라 운동하면, 그 포즈를 추출하여 레퍼런스 포즈와의 유사도를 검사, 점수화 해 제공하여 피드백을 줍니다.

## 사용 라이브러리
+ [Vision](https://developer.apple.com/documentation/vision/detecting_human_body_poses_in_images) : 애플 공식 컴퓨터비전 프레임워크
+ [SnapKit](https://github.com/SnapKit/SnapKit) : Auto Layout을 코드만으로 설정할 수 있도록 도와주는 라이브러리
+ [RxSwift](https://github.com/ReactiveX/RxSwift) : 비동기, 이벤트 기반 프로그래밍 라이브러리
+ [Nuke](https://github.com/kean/Nuke) : 이미지 캐시 라이브러리
+ [Hero](https://github.com/HeroTransitions/Hero) : 다양한 스타일의 View 전환 애니메이션을 제공하는 라이브러리
+ [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD) : 업로드/다운로드 진행상황을 보여주기 위해 사용한 라이브러리
+ [AWSS3](https://github.com/aws-amplify/aws-sdk-ios/tree/main/AWSS3) : AWS S3 인스턴스에 파일을 업로드하기위해 사용한 라이브러리

## To-do list
- [x] ~~Vision 프레임워크 사용, Pose 추출하기~~
- [x] ~~시간별 Pose 정보를 JSON형태로 저장하기~~
- [x] ~~Pose와 영상, 메타데이터를 서버에 업로드~~
- [x] ~~Pose간 유사도 비교 알고리즘 구현(유클리드 거리 비교 기반)~~
- [ ] 유사도 비교 성능 개선 (coreML 사용 등)
- [ ] 프로필 기능 추가
- [ ] 리더보드 기능 추가
- [ ] App Store 출시해보기

## Poster
> Metamong은 충남대학교 2021 CNU SW/AI ProjectFair 창의작품경진대회 출품작입니다.  

![포스터](./screenshots/poster.png)

## Developers
<table>
  <tr>
    <td align="center"><a href="https://github.com/Yabby1997"><img src="https://avatars.githubusercontent.com/yabby1997" width="100px;" alt=""/><br /><sub><b>Seunghun Yang</b></sub></a><br /><a href="https://github.com/ProjectMetamong/PoC-iOS-Application/commits?author=yabby1997" title="commits">🧑‍💻</a><a href="https://www.notion.so/yabby/Metamong-c0a9b8f83cd84e1db819d8eb18f1a549" title="notion">📕</a></td>
    <td align="center"><a href="https://github.com/colories"><img src="https://avatars.githubusercontent.com/colories" width="100px;" alt=""/><br /><sub><b>김정현</b></sub></a><br /><a href="https://github.com/ProjectMetamong/PoC-iOS-Application/commits?author=colories" title="commits">🧑‍💻</a></td>
  </tr>
</table>


## TMI
[노션](https://www.notion.so/yabby/Metamong-c0a9b8f83cd84e1db819d8eb18f1a549)에서 개발 로그를 확인할 수 있습니다.