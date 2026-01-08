# FrontEnd
해냄 프론트엔드 레포지토리



---

## Commit Convention

커밋 메시지는 아래와 같은 형식으로 작성합니다:

### 커밋 타입
- **feat**: 새로운 기능 추가  
- **fix**: 버그 수정  
- **docs**: 문서 수정 (README, 주석 등)  
- **style**: 코드 스타일 변경  
- **refactor**: 코드 리팩토링 (기능 추가나 버그 수정 없음)  
- **test**: 테스트 코드 추가/수정  
- **chore**: 빌드, 패키지 매니저, 설정 변경 등  

### 예시
```bash
feat: 무한 스크롤 페이징 기능 추가
fix: 게시물 로딩 중 중복 호출되는 버그 수정
docs: README에 Git Flow 전략 추가
refactor: WriteViewModel 코드 최적화
```

---
## 🌳 Git Flow
프로젝트에서는 아래 브랜치 전략을 사용합니다.

### 브랜치 종류
- **main**: 실제 배포 버전  
- **develop**: 다음 배포를 준비하는 통합 브랜치  
- **feature/**: 새로운 기능 개발 브랜치  
- **release/**: 배포 준비 브랜치  
- **hotfix/**: 운영 중 긴급 수정 브랜치  

### 작업 흐름

#### 1. 기능 개발
```bash
# develop 브랜치 최신화
git checkout develop
git pull origin develop

# 새 기능 브랜치 생성
git checkout -b feature/브랜치명

# 기능 개발 후 커밋
git add .
git commit -m "feat: 글 작성 API 연동"
git push origin feature/브랜치명
```

→ 기능 개발 후 PR 생성 → 코드 리뷰 → 리뷰 완료 후 Merge (필요 시 바로 Merge)

#### 2. Merge 후 develop 최신화
```bash
# develop 브랜치 최신화
git checkout develop
git pull origin develop
```

#### 3. Release 브랜치 생성 및 배포 준비
```bash
# develop 브랜치에서 release 브랜치 생성
git checkout develop
git checkout -b release/v1.0.0

# 버전 업데이트, 빌드 테스트, 버그 수정
git commit -am "chore: release 준비 v1.0.0"

# release 브랜치 push
git push origin release/v1.0.0
```

→ PR로 release → main 병합
→ 배포 완료 후 release → develop 병합

#### 4. Hotfix (긴급 버그 수정)
```bash
git checkout main
git pull origin main
git checkout -b hotfix/버그수정

# 버그 수정 후 커밋
git commit -am "fix: 긴급 버그 수정"
git push origin hotfix/버그수정

```

→ PR로 main → merge 병합
→ 배포 완료 후 release → develop 병합

---

### 브랜치 네이밍 규칙
- `feature/기능명`  
- `fix/버그명`  
- `release/버전`  
- `hotfix/버그명`  
