- - -
title: dnf - swap command author: wale soyinka contributors: date: 2023-01-24 tags:
  - 클라우드 이미지
  - 컨테이너
  - dnf
  - dnf swap
  - curl
  - curl-minimal
  - allowerasing
  - coreutils-single
- - -


# 소개

컨테이너 이미지와 클라우드 이미지를 가능한 작게 만들기 위해 배포 유지자와 패키저들은 때로는 인기 있는 패키지의 최소화 버전을 함께 제공할 수 있습니다. 컨테이너나 클라우드 이미지와 함께 번들로 제공되는 최소화된 패키지의 예로는 **vim-minimal, curl-minimal, coreutils-single** 등이 있습니다.

실제로 제공되는 패키지 중 일부는 최소화된 버전이지만, 대부분의 사용 사례에서 충분히 사용할 수 있습니다.

그러나 최소화된 패키지로는 충분하지 않은 경우 `dnf swap` 명령을 사용하여 빠르게 최소화된 패키지를 일반 패키지로 교체할 수 있습니다.

# 목적

이 Rocky Linux GEMstone에서는 **dnf**를 사용하여 번들로 제공된 `curl-minimal` 패키지를 일반 `curl` 패키지로 _교체_ 하는 방법을 보여줍니다.


## 기존 curl 변형 확인

관리 권한이 있는 사용자로 컨테이너나 가상 머신 환경에 로그인한 상태에서 먼저 설치된 `curl` 패키지의 변형을 확인합니다. 다음을 입력하세요.

```bash
# rpm -qa | grep  ^curl-minimal
curl-minimal-*
```

데모 시스템에 curl-minimal이 설치되어 있습니다!


## curl을 위한 curl-minimal 변환

`dnf`를 사용하여 설치된 `curl-minimal` 패키지를 일반 `curl` 패키지로 교체합니다.

```bash
# dnf -y swap curl-minimal curl

```

## 새로운 curl 패키지 변형 확인

변경 사항을 확인하기 위해 rpm 데이터베이스를 다시 쿼리하여 설치된 curl 패키지를 확인합니다.

```bash
# rpm -qa | grep  ^curl
curl-*
```


그리고 이는 GEM입니다!


## 참고 사항

DNF Swap 명령

**귀하**가 이 스텁에 잘 맞는 예제가 있다면 언제든지 변경해 추가해 주세요.

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

실제로 `dnf swap`은 패키지 충돌 문제를 해결하기 위해 DNF의 `--allowerasing` 옵션을 사용합니다. 따라서 이 GEMstone에서 설명하는 curl 최소화 예제는 다음과 같이 실행하여도 동일한 결과를 얻을 수 있습니다.


```bash
dnf install -y --allowerasing curl
```



