/// 최초 작성자: 정승빈
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/features/social/friend_edit_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'friend_add_screen.dart';
import 'social_repository.dart';
import 'social_model.dart';

/// 클래스의 용도: 친구 목록 제공 및 초성 검색 기능이 포함된 소셜 메인 화면
class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  // 리포지토리 인스턴스 참조
  final SocialRepository _repository = SocialRepository();
  final TextEditingController searchController = TextEditingController();

  late List<Friend> totalFriendList;
  List<Friend> filteredFriendList = [];

  // 한글 정규표현식 및 초성 추출 관련 상수
  static const String KOREAN_REGEX = r'^[가-힣]';
  static const int HANGEUL_BASE = 0xAC00;
  static const List<String> CHOSEONG_LIST = [
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ];

  /// 함수의 용도: 초기 데이터 설정 및 정렬 수행
  /// 매개 변수: 없음
  /// 반환 값: 없음
  @override
  void initState() {
    super.initState();
    totalFriendList = _repository.friends;
    filteredFriendList = List.from(totalFriendList);
    sortFriendList(filteredFriendList);
  }

  /// 함수의 용도: 컨트롤러 해제 등 리소스 정리
  /// 매개 변수: 없음
  /// 반환 값: 없음
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// 함수의 용도: 입력된 쿼리에 따라 친구 목록을 필터링
  /// 매개 변수: String query (검색어)
  /// 반환 값: 없음
  void filterFriendList(String query) {
    setState(() {
      String trimmedQuery = query.trim().toLowerCase();
      if (trimmedQuery.isEmpty) {
        filteredFriendList = List.from(totalFriendList);
      } else {
        filteredFriendList = totalFriendList.where((friend) {
          String friendName = friend.name.toLowerCase();
          if (friendName.contains(trimmedQuery)) return true;
          return getChoseongString(friendName).contains(trimmedQuery);
        }).toList();
      }
      sortFriendList(filteredFriendList);
    });
  }

  /// 함수의 용도: 한글 문자열에서 초성만 추출하여 반환
  /// 매개 변수: String text (원본 문자열)
  /// 반환 값: String (추출된 초성 문자열)
  String getChoseongString(String text) {
    String result = "";
    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      // 한글 유니코드 범위 내에 있는지 확인
      if (charCode >= 0xAC00 && charCode <= 0xD7A3) {
        int choseongIndex = (charCode - HANGEUL_BASE) ~/ (21 * 28);
        result += CHOSEONG_LIST[choseongIndex];
      } else {
        result += text[i];
      }
    }
    return result;
  }

  /// 함수의 용도: 제공된 리스트를 가나다순으로 정렬
  /// 매개 변수: List<Friend> list (정렬할 리스트)
  /// 반환 값: 없음
  void sortFriendList(List<Friend> list) {
    list.sort((a, b) => compareKoreanFirst(a.name, b.name));
  }

  /// 함수의 용도: 한글을 우선순위로 두는 비교 로직 수행
  /// 매개 변수: String a, String b (비교 대상 문자열)
  /// 반환 값: int (비교 결과 값)
  static int compareKoreanFirst(String a, String b) {
    bool isAKorean = checkIsKorean(a);
    bool isBKorean = checkIsKorean(b);
    if (isAKorean && !isBKorean) return -1;
    if (!isAKorean && isBKorean) return 1;
    return a.compareTo(b);
  }

  /// 함수의 용도: 정규표현식을 통해 한글 여부 확인
  /// 매개 변수: String text
  /// 반환 값: bool (한글 포함 여부)
  static bool checkIsKorean(String text) {
    if (text.isEmpty) return false;
    return RegExp(KOREAN_REGEX).hasMatch(text);
  }

  /// 함수의 용도: 메인 빌드 메서드
  /// 매개 변수: BuildContext context (빌드 컨텍스트)
  /// 반환 값: Widget (완성된 화면 위젯)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: Column(
        children: [
          buildFixedHeader(filteredFriendList.length),
          Expanded(child: buildFriendListView()),
        ],
      ),
    );
  }

  /// 함수의 용도: 화면 상단 앱바 생성
  /// 매개 변수: BuildContext context
  /// 반환 값: PreferredSizeWidget
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text('친구', style: AppTypography.h2),
      actions: [
        IconButton(
          onPressed: () async {
            // 친구 추가 화면에서 돌아왔을 때 목록을 새로고침하기 위해 await 사용
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FriendAddScreen()),
            );
            // 돌아온 후 UI 갱신
            setState(() {
              filterFriendList(searchController.text);
            });
          },
          icon: SvgPicture.asset(
            'assets/images/icons/friend_add_icon.svg',
            width: 24,
            height: 24,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  /// 함수의 용도: 검색창과 편집 버튼을 포함한 헤더 빌드
  /// 매개 변수: int count (친구 수)
  /// 반환 값: Widget
  Widget buildFixedHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gray4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/icons/search_icon.svg',
                  width: 18,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gray3,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: filterFriendList,
                    decoration: const InputDecoration(
                      hintText: '친구 검색',
                      hintStyle: AppTypography.b2,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: AppTypography.b2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '친구 $count',
                style: AppTypography.b2,
                selectionColor: AppColors.black,
              ),
              GestureDetector(
                onTap: () async {
                  // 편집 화면으로 이동하고 수정된 리스트를 기다림
                  final List<Friend>? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FriendEditScreen(initialFriends: totalFriendList),
                    ),
                  );

                  // 만약 리스트가 수정되어 돌아왔다면(result가 null이 아니라면) 화면 업데이트
                  if (result != null) {
                    setState(() {
                      totalFriendList.clear();
                      totalFriendList.addAll(result);
                      // 현재 검색어에 맞춰 필터링 리스트 다시 적용
                      filterFriendList(searchController.text);
                    });
                  }
                },
                child: const Text(
                  '편집',
                  style: AppTypography.b2,
                  selectionColor: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// 함수의 용도: 필터링된 친구 목록 리스트뷰 빌드
  /// 매개 변수: 없음
  /// 반환 값: Widget
  Widget buildFriendListView() {
    if (filteredFriendList.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.', style: AppTypography.b2));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredFriendList.length,
      itemBuilder: (context, index) =>
          buildFriendTile(filteredFriendList[index]),
    );
  }

  /// 함수의 용도: 개별 친구 항목 타일 생성
  /// 매개 변수: Friend friend (친구 데이터 모델)
  /// 반환 값: Widget
  Widget buildFriendTile(Friend friend) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x7FDFE1DC),
              shape: BoxShape.circle,
              image: friend.profileImage != null
                  ? DecorationImage(
                      image: AssetImage(friend.profileImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: friend.profileImage == null
                ? Center(
                    child: SvgPicture.asset(
                      'assets/images/icons/default_profile_icon.svg',
                      width: 24,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(friend.name, style: AppTypography.h3.copyWith(fontSize: 15)),
              Text(
                friend.title,
                style: AppTypography.c1.copyWith(color: AppColors.gray2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
